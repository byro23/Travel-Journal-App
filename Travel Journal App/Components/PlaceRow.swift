import SwiftUI

// MARK: - View
struct PlaceRow: View { // Provides the presentation of the rows in favourite hikes list
    
    // MARK: - Properties
    let place: Place
    
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(place.placeName)
                .font(.headline)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(place.placeAddress)
                .font(.caption)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    PlaceRow(place: Place(placeName: "Walter Hartwell White's House", placeAddress: "Albuquerque, New Mexico", latitude: 35.0844, longitude: 106.6504))
}
