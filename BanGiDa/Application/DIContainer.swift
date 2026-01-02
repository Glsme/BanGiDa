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
        
        // MARK: - Repositories
        
        container.register(UserRepository.self) { _ in
            UserRepositoryImpl()
        }
        .inObjectScope(.container)
        
        container.register(StoryRepository.self) { _ in
            StoryRepositoryImpl()
        }
        .inObjectScope(.container)

        
        // MARK: - UseCases
        
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
        
        container.register(UpdateNicknameUseCase.self) { resolver in
            guard let userRepository = resolver.resolve(UserRepository.self) else {
                fatalError("UserRepository dependency has not been registered.")
            }
            return UpdateNicknameUseCaseImpl(userRepository: userRepository)
        }
        
        container.register(WriteStoryUseCase.self) { resolver in
            guard let storyRepository = resolver.resolve(StoryRepository.self) else {
                fatalError("StoryRepository dependency has not been registered.")
            }
            
            guard let userRepository = resolver.resolve(UserRepository.self) else {
                fatalError("UserRepository dependency has not been registered.")
            }
            
            return WriteStoryUseCaseImpl(
                storyRepository: storyRepository,
                userRepository: userRepository
            )
        }
    }
}
