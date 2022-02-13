import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Image(systemName: "location.viewfinder")
                    Text("Map")
                }
            RoutesView()
                .tabItem {
                    Image(systemName: "bookmark")
                    Text("Routes")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
