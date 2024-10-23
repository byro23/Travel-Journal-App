import SwiftUI

// MARK: - View
struct PlaceRow: View { // Provides the presentation of the rows in favourite hikes list
    
    // MARK: - Properties
    let place: Place
    
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading) {
            Text(place.placeName)
                .font(.headline)
            Text(place.placeAddress)
                .font(.subheadline)
        }
    }
}
