import ProjectDescription

let config = Config(
    compatibleXcodeVersions: .all,
    swiftVersion: "5.10",
    generationOptions: .options(
        // TODO: Firebase SPM 통합 안정화 후 true로 변경
        enforceExplicitDependencies: false
    )
)
