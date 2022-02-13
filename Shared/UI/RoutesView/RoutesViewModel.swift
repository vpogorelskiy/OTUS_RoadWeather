import Foundation

struct RouteItem: Identifiable {
    var id: String {
        title
    }
    
    let title: String
}

class RoutesViewModel: ObservableObject {
    var routes: [RouteItem] = [] //Array(repeating: RouteItem(title: "Some route"), count: 5)
}
