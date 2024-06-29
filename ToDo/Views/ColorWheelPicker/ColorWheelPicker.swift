import SwiftUI

struct ColorWheelPicker: View {
    @Binding var color: Color
    
    @State var hue: Double = 0
    @State var saturation: Double = 1
    @State var brightness: Double = 1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Rectangle()
                .fill(color)
                .clipShape(.capsule)
                .frame(width: 80, height: 24)
            
            ColorWheel(hue: $hue, saturation: $saturation)
            
            VStack(alignment: .leading, spacing: 8) {
                Label(
                    title: {
                        HStack {
                            Text("Яркость: ")
                                .bold()
                            Spacer()
                            Text("\(Int(brightness * 100))%")
                        }
                        
                    },
                    icon: {
                        withAnimation {
                            Image(systemName: "aqi.medium", variableValue: brightness)
                                .bold()
                        }
                    }
                )
                
                Slider(value: $brightness, in: 0...1) {
                    Text("\(Int(brightness * 100))%")
                }
            }
        }
        .onChange(of: brightness) {
            color = Color(hue: hue, saturation: saturation, brightness: brightness)
        }
        .onChange(of: hue) {
            color = Color(hue: hue, saturation: saturation, brightness: brightness)
        }
        .padding()
    }
}

#Preview {
    ColorWheelPicker(color: .constant(.red))
}
