import SwiftUI

struct ColorWheel: View {
    @Binding var hue: Double
    @Binding var saturation: Double
    
    @State private var location: CGPoint?
    @State private var center: CGPoint = CGPoint(
        x: UIScreen.main.bounds.size.width * 0.5,
        y: UIScreen.main.bounds.size.height * 0.5
    )
    
    let radius: CGFloat = 120
    var diameter: CGFloat {
        radius * 2
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(
                        AngularGradient(gradient: Gradient(colors: [
                            Color(hue: 1.0, saturation: 1, brightness: 1),
                            Color(hue: 0.9, saturation: 1, brightness: 1),
                            Color(hue: 0.8, saturation: 1, brightness: 1),
                            Color(hue: 0.7, saturation: 1, brightness: 1),
                            Color(hue: 0.6, saturation: 1, brightness: 1),
                            Color(hue: 0.5, saturation: 1, brightness: 1),
                            Color(hue: 0.4, saturation: 1, brightness: 1),
                            Color(hue: 0.3, saturation: 1, brightness: 1),
                            Color(hue: 0.2, saturation: 1, brightness: 1),
                            Color(hue: 0.1, saturation: 1, brightness: 1),
                            Color(hue: 0, saturation: 1, brightness: 1)
                        ]), center: .center)
                    )
                    .frame(width: diameter, height: diameter)
                    .position(center)
                    .overlay(
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(
                                        colors: [
                                            .white,
                                            .white.opacity(0)
                                        ]
                                    ),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: radius
                                )
                            )
                            .position(center)
                    )
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            self.center = center
                        }
                    }
                
                
                if let location = location {
                    Circle()
                        .stroke(.white, lineWidth: 8)
                        .fill(Color(hue: hue, saturation: saturation, brightness: 1))
                        .foregroundStyle(.cyan)
                        .shadow(radius: 16, y: 2)
                        .frame(width: 44, height: 44)
                        .position(location)
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(dragGesture)
        }
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                location = value.location
                
                let distanceX = value.location.x - center.x
                let distanceY = value.location.y - center.y
                
                let direction = CGPoint(x: distanceX, y: distanceY)
                var distance = sqrt(distanceX * distanceX + distanceY * distanceY)
                
                if distance < radius {
                    location = value.location
                } else {
                    let clampedX = direction.x / distance * radius
                    let clampedY = direction.y / distance * radius
                    
                    location = CGPoint(x: center.x + clampedX, y: center.y + clampedY)
                    distance = radius
                }
                
                if distance == 0 { return }
                
                var angle = Angle(radians: -Double(atan(direction.y / direction.x)))
                if direction.x < 0 {
                    angle.degrees += 180
                } else if direction.x > 0 && direction.y > 0 {
                    angle.degrees += 360
                }
                
                hue = angle.degrees / 360
                saturation = Double(distance / radius)
            }
            .onEnded { value in
                location = nil
            }
    }
}

#Preview {
    ColorWheel(hue: .constant(0), saturation: .constant(1))
}
