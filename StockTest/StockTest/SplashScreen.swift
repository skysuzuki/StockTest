//
//  SplashScreen.swift
//  StockTest
//
//  Created by Lambda_School_Loaner_204 on 2/14/21.
//

import Foundation
import SwiftUI

struct SplashScreen: View {
    static var shouldAnimate = true

    let backgroundColor = Color("launchScreenBackground")
    @State var textAlpha = 0.0
    @State var textScale: CGFloat = 1
    @State var percent = 0.0
    @State var oScale: CGFloat = 1
    @State var circleColor = Color.black
    @State var circleScale: CGFloat = 1
    let oLineWidth: CGFloat = 5
    let oZoomFactor: CGFloat = 1.4
    let oCircleLength: CGFloat = 20

    var body: some View {
        ZStack {
            Text("ST           CKS")
                .font(.largeTitle)
                .foregroundColor(.black)
                .opacity(textAlpha)
                .offset(x: 10,
                        y: 0)
                .scaleEffect(textScale)
            StockO(percent: percent)
                .stroke(Color.black, lineWidth: oLineWidth)
                .rotationEffect(.degrees(-90))
                .aspectRatio(1, contentMode: .fit)
                .padding(20)
                .onAppear() {
                    self.handleAnimations()
                }
                .scaleEffect(oScale * oZoomFactor)
                .frame(width: 45, height: 45, alignment: .center)
            Circle()
                .fill(circleColor)
                .scaleEffect(circleScale * oZoomFactor)
                .frame(width: oCircleLength,
                       height: oCircleLength,
                       alignment: .center)
                .onAppear() {
                    self.circleColor = self.backgroundColor
                }
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(backgroundColor)
        .edgesIgnoringSafeArea(.all)

    }
}

extension SplashScreen {
    var oAnimationDuration: Double { return 1.0 }
    var oAnimationDelay: Double { return 0.2 }
    var oExitAnimationDuration: Double { return 0.3 }
    var finalAnimationDuration: Double { return 0.4 }
    var minAnimationInterval: Double { return 0.1 }
    var fadeAnimationDuration: Double { return 0.4 }

    func handleAnimations() {
        runAnimationPart1()
        runAnimationPart2()
        runAnimationPart3()
        if SplashScreen.shouldAnimate {
            restartAnimation()
        }
    }

    func runAnimationPart1() {
        // Text intro Animation
        withAnimation(Animation.easeIn(duration: oAnimationDuration).delay(0.5)) {
            textAlpha = 1.0
        }

        // "O" Animation
        withAnimation(.easeIn(duration: oAnimationDuration)) {
            percent = 1
            oScale = 4
        }
        let deadline: DispatchTime = .now() + oAnimationDuration + oAnimationDelay
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            withAnimation(.easeOut(duration: self.oExitAnimationDuration)) {
                self.oScale = 0
            }
            withAnimation(.easeOut(duration: self.minAnimationInterval)) {
                self.circleScale = 0
            }
        }

        // Text spring animation
        withAnimation(Animation.spring()) {

        }
    }

    func runAnimationPart2() {
        let deadline: DispatchTime = .now() + oAnimationDuration + oAnimationDelay + minAnimationInterval
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.circleColor = Color.black
            self.circleScale = 1
        }
    }

    func runAnimationPart3() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2 * oAnimationDuration) {
            withAnimation(.easeIn(duration: self.finalAnimationDuration)) {
                self.textAlpha = 0
                self.circleColor = self.backgroundColor
            }
        }
    }

    func restartAnimation() {
        let deadline: DispatchTime = .now() + 2 * oAnimationDuration + finalAnimationDuration
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.percent = 0
            self.textScale = 1
            self.handleAnimations()
        }
    }
}

struct StockO: Shape {
    var percent: Double

    func path(in rect: CGRect) -> Path {
        let end = percent * 360
        var p = Path()

        p.addArc(center: CGPoint(x: rect.size.width / 2, y: rect.size.width / 2),
                 radius: rect.size.width / 2,
                 startAngle: Angle(degrees: 0),
                 endAngle: Angle(degrees: end),
                 clockwise: false)

        return p
    }

    var animatableData: Double {
        get { return percent }
        set { percent = newValue }
    }
}

struct SplashScreen_Previews : PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
