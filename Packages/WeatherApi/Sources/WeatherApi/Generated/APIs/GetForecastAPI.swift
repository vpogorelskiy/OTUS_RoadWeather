//
// GetForecastAPI.swift
//
// Generated by openapi-generator
// https://openapi-generator.tech
//

import Foundation
#if canImport(AnyCodable)
import AnyCodable
#endif

open class GetForecastAPI {

    /**
     List api.openweathermap.org 2.5s
     
     - parameter apiKey: (query) apiKey (optional)
     - parameter lat: (query) lat (optional)
     - parameter lon: (query) lon (optional)
     - parameter units: (query) units (optional)
     - parameter exclude: (query) exclude (optional)
     - parameter apiResponseQueue: The queue on which api response is dispatched.
     - parameter completion: completion handler to receive the data and the error objects
     */
    @discardableResult
    open class func getForecast(apiKey: String? = nil, lat: String? = nil, lon: String? = nil, units: String? = nil, exclude: String? = nil, apiResponseQueue: DispatchQueue = OpenAPIClientAPI.apiResponseQueue, completion: @escaping ((_ data: ModelResponse?, _ error: Error?) -> Void)) -> RequestTask {
        return getForecastWithRequestBuilder(apiKey: apiKey, lat: lat, lon: lon, units: units, exclude: exclude).execute(apiResponseQueue) { result in
            switch result {
            case let .success(response):
                completion(response.body, nil)
            case let .failure(error):
                completion(nil, error)
            }
        }
    }

    /**
     List api.openweathermap.org 2.5s
     - GET /onecall/
     - One call
     - parameter apiKey: (query) apiKey (optional)
     - parameter lat: (query) lat (optional)
     - parameter lon: (query) lon (optional)
     - parameter units: (query) units (optional)
     - parameter exclude: (query) exclude (optional)
     - returns: RequestBuilder<ModelResponse> 
     */
    open class func getForecastWithRequestBuilder(apiKey: String? = nil, lat: String? = nil, lon: String? = nil, units: String? = nil, exclude: String? = nil) -> RequestBuilder<ModelResponse> {
        let localVariablePath = "/onecall/"
        let localVariableURLString = OpenAPIClientAPI.basePath + localVariablePath
        let localVariableParameters: [String: Any]? = nil

        var localVariableUrlComponents = URLComponents(string: localVariableURLString)
        localVariableUrlComponents?.queryItems = APIHelper.mapValuesToQueryItems([
            "apiKey": apiKey?.encodeToJSON(),
            "lat": lat?.encodeToJSON(),
            "lon": lon?.encodeToJSON(),
            "units": units?.encodeToJSON(),
            "exclude": exclude?.encodeToJSON(),
        ])

        let localVariableNillableHeaders: [String: Any?] = [
            :
        ]

        let localVariableHeaderParameters = APIHelper.rejectNilHeaders(localVariableNillableHeaders)

        let localVariableRequestBuilder: RequestBuilder<ModelResponse>.Type = OpenAPIClientAPI.requestBuilderFactory.getBuilder()

        return localVariableRequestBuilder.init(method: "GET", URLString: (localVariableUrlComponents?.string ?? localVariableURLString), parameters: localVariableParameters, headers: localVariableHeaderParameters)
    }
}
