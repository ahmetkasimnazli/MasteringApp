import SwiftUI
import RevenueCatUI
import RevenueCat

struct StoreView: View {
    @EnvironmentObject private var viewModel: DolbyIOViewModel
    @State private var products: [Package]?
    @State private var displayPaywall = false

    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 150))
    ]

    var body: some View {
        ScrollView{
            LazyVGrid(columns: adaptiveColumn, spacing: 30) {
                if let products = products {
                    ForEach(products, id: \.identifier) { product in
                        VStack {
                            Image(systemName: "circle.dashed.inset.filled")
                                .foregroundStyle(.yellow)
                                .font(.system(size: 50))
                                .glow()
                                .frame(width: 100, height: 100)


                            Text(product.storeProduct.localizedDescription)
                            Text(product.storeProduct.localizedPriceString)
                                .bold()
                                .font(.title3)
                        }
                        .onTapGesture {
                            viewModel.purchaseProduct(product)
                        }
                        .padding()
                        .frame(minWidth: 150)
                        .background(.ultraThinMaterial)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 20,
                                style: .continuous
                            ))

                    }
                }
            }.padding()

                Text("OR")
                    .bold()
                    .font(.title2)
            Button{
                displayPaywall.toggle()
            }label: {
                Text("SUBSCRIBE")
                    .padding()
            }
                .buttonStyle(.borderedProminent)
                .bold()
                .tint(.green)
                .font(.system(size: 30))
                .foregroundStyle(.white)
                .glow()
            }

            .navigationTitle("Store")

        .sheet(isPresented: self.$displayPaywall) {
            PaywallView(displayCloseButton: true)
        }
        .onAppear{
            viewModel.fetchProducts()
        }
        .onReceive(viewModel.$products) { products in
            self.products = products
        }
    }
}


#Preview {
    StoreView()
        .environmentObject(DolbyIOViewModel())
}
