SWIFT_MODULE_SRC="Sources/WeatherApi/Generated/"
openapi-generator generate -i "openweathermap.yaml" -g swift5 -o "api-mobile"
rm -r $SWIFT_MODULE_SRC""*
mkdir -p $SWIFT_MODULE_SRC
cp -R "api-mobile/OpenAPIClient/Classes/OpenAPIs/". $SWIFT_MODULE_SRC
rm -r "api-mobile"
