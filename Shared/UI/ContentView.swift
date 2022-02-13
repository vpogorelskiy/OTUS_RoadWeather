import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RoutesView()
                .tabItem {
                    Image(systemName: "bookmark")
                    Text("Routes")
                }
            MapView()
                .tabItem {
                    Image(systemName: "location.viewfinder")
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
