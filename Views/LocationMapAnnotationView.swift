//
//  LocationMapAnnotationView.swift
//  CWK2Template
//
import SwiftUI

// Custom View to display custom annotation pin in map
struct LocationMapAnnotationView: View {
    var body: some View {
        VStack{
            // taken an icon from SF Symbols - white map mark within red triangle and red triangle resized
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 20,height: 20)
                .font(.headline)
                .foregroundColor(.red)
                .background(.white)
                .cornerRadius(20)
            
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 15,height: 15)
                .foregroundColor(.red)
                .rotationEffect(Angle(degrees: 180))
                .offset(y:-14)
        }
    }
}

struct LocationMapAnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            Color.black.ignoresSafeArea()
            LocationMapAnnotationView().environmentObject(WeatherMapViewModel())
        }
    }
}
