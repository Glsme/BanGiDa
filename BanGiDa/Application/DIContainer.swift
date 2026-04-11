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

        container.register(DiaryRepository.self) { _ in
            RealmDiaryRepository()
        }
        .inObjectScope(.container)

        container.register(ImageRepository.self) { _ in
            ImageRepositoryImpl()
        }
        .inObjectScope(.container)

        container.register(UserPreferencesRepository.self) { _ in
            UserPreferencesRepositoryImpl()
        }
        .inObjectScope(.container)

        container.register(NotificationRepository.self) { _ in
            NotificationRepositoryImpl()
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

        container.register(FetchStoriesUseCase.self) { resolver in
            guard let storyRepository = resolver.resolve(StoryRepository.self) else {
                fatalError("StoryRepository dependency has not been registered.")
            }
            
            guard let userRepository = resolver.resolve(UserRepository.self) else {
                fatalError("UserRepository dependency has not been registered.")
            }
            
            return FetchStoriesUseCaseImpl(
                storyRepository: storyRepository,
                userRepository: userRepository
            )
        }
        
        container.register(ToggleStoryLikeUseCase.self) { resolver in
            guard let storyRepository = resolver.resolve(StoryRepository.self) else {
                fatalError("StoryRepository dependency has not been registered.")
            }
            
            guard let userRepository = resolver.resolve(UserRepository.self) else {
                fatalError("UserRepository dependency has not been registered.")
            }
            
            return ToggleStoryLikeUseCaseImpl(
                storyRepository: storyRepository,
                userRepository: userRepository
            )
        }
        
        container.register(ReportStoryUseCase.self) { resolver in
            guard let storyRepository = resolver.resolve(StoryRepository.self) else {
                fatalError("StoryRepository dependency has not been registered.")
            }

            guard let userRepository = resolver.resolve(UserRepository.self) else {
                fatalError("UserRepository dependency has not been registered.")
            }

            return ReportStoryUseCaseImpl(
                storyRepository: storyRepository,
                userRepository: userRepository
            )
        }

        // MARK: - Diary UseCases

        container.register(FetchDiariesByDateUseCase.self) { resolver in
            guard let diaryRepository = resolver.resolve(DiaryRepository.self) else {
                fatalError("DiaryRepository dependency has not been registered.")
            }
            return FetchDiariesByDateUseCaseImpl(diaryRepository: diaryRepository)
        }

        container.register(SaveDiaryUseCase.self) { resolver in
            guard let diaryRepository = resolver.resolve(DiaryRepository.self) else {
                fatalError("DiaryRepository dependency has not been registered.")
            }
            guard let imageRepository = resolver.resolve(ImageRepository.self) else {
                fatalError("ImageRepository dependency has not been registered.")
            }
            return SaveDiaryUseCaseImpl(diaryRepository: diaryRepository, imageRepository: imageRepository)
        }

        container.register(UpdateDiaryUseCase.self) { resolver in
            guard let diaryRepository = resolver.resolve(DiaryRepository.self) else {
                fatalError("DiaryRepository dependency has not been registered.")
            }
            guard let imageRepository = resolver.resolve(ImageRepository.self) else {
                fatalError("ImageRepository dependency has not been registered.")
            }
            return UpdateDiaryUseCaseImpl(diaryRepository: diaryRepository, imageRepository: imageRepository)
        }

        container.register(DeleteDiaryUseCase.self) { resolver in
            guard let diaryRepository = resolver.resolve(DiaryRepository.self) else {
                fatalError("DiaryRepository dependency has not been registered.")
            }
            guard let imageRepository = resolver.resolve(ImageRepository.self) else {
                fatalError("ImageRepository dependency has not been registered.")
            }
            return DeleteDiaryUseCaseImpl(diaryRepository: diaryRepository, imageRepository: imageRepository)
        }

        container.register(SearchDiariesUseCase.self) { resolver in
            guard let diaryRepository = resolver.resolve(DiaryRepository.self) else {
                fatalError("DiaryRepository dependency has not been registered.")
            }
            return SearchDiariesUseCaseImpl(diaryRepository: diaryRepository)
        }

        // MARK: - Image UseCases

        container.register(LoadImageUseCase.self) { resolver in
            guard let imageRepository = resolver.resolve(ImageRepository.self) else {
                fatalError("ImageRepository dependency has not been registered.")
            }
            return LoadImageUseCaseImpl(imageRepository: imageRepository)
        }

        container.register(SaveImageUseCase.self) { resolver in
            guard let imageRepository = resolver.resolve(ImageRepository.self) else {
                fatalError("ImageRepository dependency has not been registered.")
            }
            return SaveImageUseCaseImpl(imageRepository: imageRepository)
        }

        // MARK: - Alarm UseCases

        container.register(ScheduleNotificationUseCase.self) { resolver in
            guard let notificationRepository = resolver.resolve(NotificationRepository.self) else {
                fatalError("NotificationRepository dependency has not been registered.")
            }
            return ScheduleNotificationUseCaseImpl(notificationRepository: notificationRepository)
        }

        container.register(RemoveNotificationUseCase.self) { resolver in
            guard let notificationRepository = resolver.resolve(NotificationRepository.self) else {
                fatalError("NotificationRepository dependency has not been registered.")
            }
            return RemoveNotificationUseCaseImpl(notificationRepository: notificationRepository)
        }

        container.register(SaveAlarmUseCase.self) { resolver in
            guard let diaryRepository = resolver.resolve(DiaryRepository.self) else {
                fatalError("DiaryRepository dependency has not been registered.")
            }
            guard let notificationRepository = resolver.resolve(NotificationRepository.self) else {
                fatalError("NotificationRepository dependency has not been registered.")
            }
            return SaveAlarmUseCaseImpl(diaryRepository: diaryRepository, notificationRepository: notificationRepository)
        }

        // MARK: - Backup Repositories

        container.register(BackupRepository.self) { _ in
            BackupRepositoryImpl()
        }
        .inObjectScope(.container)

        // MARK: - Backup UseCases

        container.register(CreateBackupUseCase.self) { resolver in
            guard let backupRepository = resolver.resolve(BackupRepository.self) else {
                fatalError("BackupRepository dependency has not been registered.")
            }
            return CreateBackupUseCaseImpl(backupRepository: backupRepository)
        }

        container.register(RestoreBackupUseCase.self) { resolver in
            guard let backupRepository = resolver.resolve(BackupRepository.self) else {
                fatalError("BackupRepository dependency has not been registered.")
            }
            return RestoreBackupUseCaseImpl(backupRepository: backupRepository)
        }

        container.register(ResetDataUseCase.self) { resolver in
            guard let diaryRepository = resolver.resolve(DiaryRepository.self) else {
                fatalError("DiaryRepository dependency has not been registered.")
            }
            guard let notificationRepository = resolver.resolve(NotificationRepository.self) else {
                fatalError("NotificationRepository dependency has not been registered.")
            }
            guard let userPreferencesRepository = resolver.resolve(UserPreferencesRepository.self) else {
                fatalError("UserPreferencesRepository dependency has not been registered.")
            }
            return ResetDataUseCaseImpl(diaryRepository: diaryRepository, notificationRepository: notificationRepository, userPreferencesRepository: userPreferencesRepository)
        }

        container.register(RestoreNotificationsUseCase.self) { resolver in
            guard let diaryRepository = resolver.resolve(DiaryRepository.self) else {
                fatalError("DiaryRepository dependency has not been registered.")
            }
            guard let notificationRepository = resolver.resolve(NotificationRepository.self) else {
                fatalError("NotificationRepository dependency has not been registered.")
            }
            return RestoreNotificationsUseCaseImpl(diaryRepository: diaryRepository, notificationRepository: notificationRepository)
        }
    }
}
