//
//  DIContainer.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2025/01/07.
//

import Swinject

final class AppDIContainer {
    static let shared = AppDIContainer()

    let container: Container

    private init() {
        container = Container()
        registerDependencies()
    }

    private func registerDependencies() {
        container.register(UserRepository.self) { _ in
            UserRepositoryImpl()
        }
        .inObjectScope(.container)

        container.register(CreateAuthUserUseCase.self) { resolver in
            guard let userRepository = resolver.resolve(UserRepository.self) else {
                fatalError("UserRepository dependency has not been registered.")
            }
            return CreateAuthUserUseCaseImpl(userRepository: userRepository)
        }

        container.register(CheckUserRegistrationUseCase.self) { resolver in
            guard let userRepository = resolver.resolve(UserRepository.self) else {
                fatalError("UserRepository dependency has not been registered.")
            }
            return CheckUserRegistrationUseCaseImpl(userRepository: userRepository)
        }
    }
}
