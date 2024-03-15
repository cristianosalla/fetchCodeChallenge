import Foundation
import SwiftUI

protocol CategoryViewModelProtocol: ObservableObject {
    var categories: [Categories] { get }
    var showAlert: Bool { get set }
    var title: String { get }
    func fetchList() async
}

struct CategoryView<ViewModel: CategoryViewModelProtocol>:  View {
    
    @ObservedObject private var viewModel: ViewModel
    private var coordinator: Coordinator
    
    init(viewModel: ViewModel, coordinator: Coordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }
    
    var body: some View {
        if viewModel.categories.isEmpty {
            EmptyView(buttonAction: loadItems, isPresented: $viewModel.showAlert)
        } else {
            NavigationView {
                ScrollView {
                    TitleView(title: viewModel.title)
                    
                    LazyVGrid(columns: [GridItem()]) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            NavigationLink(destination: LazyView( coordinator.goToMealList(category: category.strCategory))) {
                                ZStack(alignment: .bottom) {
                                    coordinator.createItem(url: category.strCategoryThumb, text: category.strCategory)
                                        .padding(4)
                                }
                            }
                        }
//                        .scrollTransition(.animated.threshold(.visible(0.9))) { content, phase in
//                            content
//                                .opacity(phase.isIdentity ? 1 : 0)
//                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
//                                .blur(radius: phase.isIdentity ? 0 : 10)
//                        }
                    }
                    
                    .padding([.leading, .trailing])
                }
            }
        }
    }
    
    func loadItems() {
        Task {
            await viewModel.fetchList()
        }
    }
}
