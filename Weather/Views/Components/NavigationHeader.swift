import SwiftUI

struct NavigationHeader: View {
    let title: String
    let showBackButton: Bool
    let backAction: (() -> Void)?
    let rightContent: AnyView?
    
    init(title: String, 
         showBackButton: Bool = true, 
         backAction: (() -> Void)? = nil,
         @ViewBuilder rightContent: () -> some View = { EmptyView() }) {
        self.title = title
        self.showBackButton = showBackButton
        self.backAction = backAction
        self.rightContent = AnyView(rightContent())
    }
    
    var body: some View {
        HStack(spacing: 16) {
            if showBackButton {
                Button(action: {
                    backAction?()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            
            if !showBackButton {
                Spacer()
            }
            
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            rightContent
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

#Preview {
    ZStack {
        Color.blue
        NavigationHeader(title: "Settings", rightContent: {
            Button("Done") {}
                .foregroundColor(.white)
        })
    }
}