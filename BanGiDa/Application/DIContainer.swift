//
//  DIContainer.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2025/01/07.
//

import Swinject
import Domain

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

        container.register(CommentRepository.self) { _ in
            CommentRepositoryImpl()
        }
        .inObjectScope(.container)

        container.register(ProfanityFilter.self) { _ in
            BundleProfanityFilter()
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

        container.register(BackupRepository.self) { resolver in
            BackupRepositoryImpl(imageRepository: resolver.force(ImageRepository.self))
        }
        .inObjectScope(.container)

        container.register(AnalyticsRepository.self) { _ in
            AnalyticsRepositoryImpl()
        }
        .inObjectScope(.container)

        container.register(AppIconRepository.self) { _ in
            AppIconRepositoryImpl()
        }
        .inObjectScope(.container)

        container.register(AppIconRemoteRepository.self) { _ in
            AppIconRemoteRepositoryImpl()
        }
        .inObjectScope(.container)

        // MARK: - User UseCases

        container.register(CreateAuthUserUseCase.self) { resolver in
            CreateAuthUserUseCaseImpl(userRepository: resolver.force(UserRepository.self))
        }

        container.register(CheckUserRegistrationUseCase.self) { resolver in
            CheckUserRegistrationUseCaseImpl(userRepository: resolver.force(UserRepository.self))
        }

        container.register(UpdateNicknameUseCase.self) { resolver in
            UpdateNicknameUseCaseImpl(userRepository: resolver.force(UserRepository.self))
        }

        container.register(UpdateFCMTokenUseCase.self) { resolver in
            UpdateFCMTokenUseCaseImpl(userRepository: resolver.force(UserRepository.self))
        }

        container.register(CommentNotificationSettingsUseCase.self) { resolver in
            CommentNotificationSettingsUseCaseImpl(userRepository: resolver.force(UserRepository.self))
        }

        // MARK: - Story UseCases

        container.register(WriteStoryUseCase.self) { resolver in
            WriteStoryUseCaseImpl(
                storyRepository: resolver.force(StoryRepository.self),
                userRepository: resolver.force(UserRepository.self)
            )
        }

        container.register(FetchStoriesUseCase.self) { resolver in
            FetchStoriesUseCaseImpl(
                storyRepository: resolver.force(StoryRepository.self),
                commentRepository: resolver.force(CommentRepository.self),
                userRepository: resolver.force(UserRepository.self)
            )
        }

        container.register(ToggleStoryLikeUseCase.self) { resolver in
            ToggleStoryLikeUseCaseImpl(
                storyRepository: resolver.force(StoryRepository.self),
                userRepository: resolver.force(UserRepository.self)
            )
        }

        container.register(ReportStoryUseCase.self) { resolver in
            ReportStoryUseCaseImpl(
                storyRepository: resolver.force(StoryRepository.self),
                userRepository: resolver.force(UserRepository.self)
            )
        }

        // MARK: - Comment UseCases

        container.register(FetchCommentsUseCase.self) { resolver in
            FetchCommentsUseCaseImpl(
                commentRepository: resolver.force(CommentRepository.self),
                userRepository: resolver.force(UserRepository.self)
            )
        }

        container.register(WriteCommentUseCase.self) { resolver in
            WriteCommentUseCaseImpl(
                commentRepository: resolver.force(CommentRepository.self),
                userRepository: resolver.force(UserRepository.self),
                profanityFilter: resolver.force(ProfanityFilter.self)
            )
        }

        container.register(DeleteCommentUseCase.self) { resolver in
            DeleteCommentUseCaseImpl(
                commentRepository: resolver.force(CommentRepository.self),
                userRepository: resolver.force(UserRepository.self)
            )
        }

        container.register(ReportCommentUseCase.self) { resolver in
            ReportCommentUseCaseImpl(
                commentRepository: resolver.force(CommentRepository.self),
                userRepository: resolver.force(UserRepository.self)
            )
        }

        // MARK: - User UseCases (차단)

        container.register(BlockUserUseCase.self) { resolver in
            BlockUserUseCaseImpl(userRepository: resolver.force(UserRepository.self))
        }

        container.register(UnblockUserUseCase.self) { resolver in
            UnblockUserUseCaseImpl(userRepository: resolver.force(UserRepository.self))
        }

        container.register(FetchBlockedUsersUseCase.self) { resolver in
            FetchBlockedUsersUseCaseImpl(userRepository: resolver.force(UserRepository.self))
        }

        // MARK: - Diary UseCases

        container.register(FetchDiariesByDateUseCase.self) { resolver in
            FetchDiariesByDateUseCaseImpl(diaryRepository: resolver.force(DiaryRepository.self))
        }

        container.register(SaveDiaryUseCase.self) { resolver in
            SaveDiaryUseCaseImpl(
                diaryRepository: resolver.force(DiaryRepository.self),
                imageRepository: resolver.force(ImageRepository.self)
            )
        }

        container.register(UpdateDiaryUseCase.self) { resolver in
            UpdateDiaryUseCaseImpl(
                diaryRepository: resolver.force(DiaryRepository.self),
                imageRepository: resolver.force(ImageRepository.self)
            )
        }

        container.register(DeleteDiaryUseCase.self) { resolver in
            DeleteDiaryUseCaseImpl(
                diaryRepository: resolver.force(DiaryRepository.self),
                imageRepository: resolver.force(ImageRepository.self)
            )
        }

        container.register(SearchDiariesUseCase.self) { resolver in
            SearchDiariesUseCaseImpl(diaryRepository: resolver.force(DiaryRepository.self))
        }

        // MARK: - Image UseCases

        container.register(LoadImageUseCase.self) { resolver in
            LoadImageUseCaseImpl(imageRepository: resolver.force(ImageRepository.self))
        }

        container.register(SaveImageUseCase.self) { resolver in
            SaveImageUseCaseImpl(imageRepository: resolver.force(ImageRepository.self))
        }

        // MARK: - Preferences UseCase

        container.register(UserPreferencesUseCase.self) { resolver in
            UserPreferencesUseCaseImpl(userPreferencesRepository: resolver.force(UserPreferencesRepository.self))
        }

        container.register(FindDiaryByIDUseCase.self) { resolver in
            FindDiaryByIDUseCaseImpl(diaryRepository: resolver.force(DiaryRepository.self))
        }

        // MARK: - Alarm UseCases

        container.register(ScheduleNotificationUseCase.self) { resolver in
            ScheduleNotificationUseCaseImpl(notificationRepository: resolver.force(NotificationRepository.self))
        }

        container.register(RemoveNotificationUseCase.self) { resolver in
            RemoveNotificationUseCaseImpl(notificationRepository: resolver.force(NotificationRepository.self))
        }

        container.register(RequestNotificationAuthorizationUseCase.self) { resolver in
            RequestNotificationAuthorizationUseCaseImpl(notificationRepository: resolver.force(NotificationRepository.self))
        }

        container.register(SaveAlarmUseCase.self) { resolver in
            SaveAlarmUseCaseImpl(
                diaryRepository: resolver.force(DiaryRepository.self),
                notificationRepository: resolver.force(NotificationRepository.self)
            )
        }

        container.register(UpdateAlarmUseCase.self) { resolver in
            UpdateAlarmUseCaseImpl(
                diaryRepository: resolver.force(DiaryRepository.self),
                notificationRepository: resolver.force(NotificationRepository.self)
            )
        }

        // MARK: - Backup UseCases

        container.register(CreateBackupUseCase.self) { resolver in
            CreateBackupUseCaseImpl(backupRepository: resolver.force(BackupRepository.self))
        }

        container.register(RestoreBackupUseCase.self) { resolver in
            RestoreBackupUseCaseImpl(backupRepository: resolver.force(BackupRepository.self))
        }

        container.register(ResetDataUseCase.self) { resolver in
            ResetDataUseCaseImpl(
                diaryRepository: resolver.force(DiaryRepository.self),
                notificationRepository: resolver.force(NotificationRepository.self),
                userPreferencesRepository: resolver.force(UserPreferencesRepository.self),
                imageRepository: resolver.force(ImageRepository.self)
            )
        }

        container.register(RestoreNotificationsUseCase.self) { resolver in
            RestoreNotificationsUseCaseImpl(
                diaryRepository: resolver.force(DiaryRepository.self),
                notificationRepository: resolver.force(NotificationRepository.self)
            )
        }

        // MARK: - AppIcon UseCase

        container.register(SyncAppIconUseCase.self) { resolver in
            SyncAppIconUseCaseImpl(
                appIconRepository: resolver.force(AppIconRepository.self),
                appIconRemoteRepository: resolver.force(AppIconRemoteRepository.self)
            )
        }
    }
}

private extension Resolver {
    func force<Service>(_ serviceType: Service.Type) -> Service {
        guard let service = resolve(serviceType) else {
            assertionFailure("\(serviceType) is not registered in DIContainer.")
            // 해소 실패는 DIContainer 등록 누락이라는 명백한 프로그래머 오류이므로 즉시 종료한다.
            return resolve(serviceType)!
        }
        return service
    }
}
