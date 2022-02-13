import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RoutesView()
                .tabItem {
                    Image(systemName: "")
                    Text("Routes")
                }
            MapView()
                .tabItem {
                    Image(systemName: "")
                    Text("Map")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
