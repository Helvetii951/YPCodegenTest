# YPCodegenTest
## Ошибка при выполнении запроса `GET /stations_list/`

Скорее всего, в `openapi.yaml` прописан только ответ с форматом `application/json`. Но этот запрос возвращает `text/html`.

<a href="https://ibb.co/rc9JCBS"><img src="https://i.ibb.co/LJKfLTW/2024-03-11-09-49-09.png" alt="2024-03-11-09-49-09" border="0"></a>

Поэтому сгенеренный клиент выкидывает ошибку.
 
Нужно поправить yaml-файл:

```yaml
paths:
  /stations_list/:
    get:
      tags:
        - stations_list
...
      responses:
        200':
          description: Hierarchical list of countries, regions, settlements, and stations.
          content:
            text/html:
              schema:
                $ref: '#/components/schemas/StationsList'
...
```

Так будет выглядеть сервис:

```swift
import OpenAPIRuntime
import OpenAPIURLSession
import Foundation

typealias StationsList = Components.Schemas.StationsList

protocol  NetworkServiceProtocol {
    func  getListOfAllStations() async  throws -> StationsList
}

final  class  NetworkService: NetworkServiceProtocol {
    private let client: Client
    private  let  apikey: String
	
    init(client: Client, apikey: String) {
        self.client = client
        self.apikey = apikey
    }

    func  getListOfAllStations() async  throws -> StationsList {
        let response = try await client.getStationsList(query: .init(apikey: apikey))
        let httpBody = try response.ok.body.html
        let data = try await Data(collecting: httpBody, upTo: 100 * 1024 * 1024)
        let stationList = try JSONDecoder().decode(StationsList.self, from: data)
        // более элегантное решение
        //  let stationList = try await JSONDecoder().decode(from: httpBody, to: StationsList.self)
        return stationList
    }
}

extension  JSONDecoder {
    func decode<T: Decodable>(from httpBody: HTTPBody, to type: T.Type, upTo maxBytes: Int = 100 * 1024 * 1024) async throws -> T {
        let data = try await Data(collecting: httpBody, upTo: maxBytes)
        return try self.decode(T.self, from: data)
    }
}
```
