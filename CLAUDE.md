# CLAUDE.md

이 파일은 이 저장소에서 코드 작업을 할 때 Claude Code (claude.ai/code)에게 가이드를 제공합니다.

## 개요

Reality Composer Pro를 사용하여 객체 추적 기능을 시연하는 visionOS 샘플 프로젝트입니다. 이 앱은 실제 세계의 Apple Magic Keyboard를 추적하고 그 위에 인터랙티브한 디지털 콘텐츠를 오버레이하여 매력적인 키보드 기반 게임 경험을 제공합니다.

**중요**: 이 샘플은 visionOS 2 이상이 필요하며, 물리적인 Apple Vision Pro 기기에서만 실행할 수 있습니다 (시뮬레이터에서는 ARKit이 지원되지 않으므로 실행 불가).

**관련 세션**: WWDC24 session 100101: Explore object tracking for visionOS

## 빌드 및 실행

### 프로젝트 빌드
```bash
# 프로젝트 빌드
xcodebuild -project 3.xcodeproj -scheme ObjectTrackingExperiencesSample -destination 'platform=visionOS'

# 빌드 폴더 정리
xcodebuild clean -project 3.xcodeproj -scheme ObjectTrackingExperiencesSample
```

### 실행
이 프로젝트는 visionOS 2 이상이 설치된 물리적인 Apple Vision Pro 기기에서 실행해야 합니다. Xcode에서 `3.xcodeproj`를 열고 기기에서 `ObjectTrackingExperiencesSample` 스킴을 실행하세요.

## 아키텍처

### 앱 구조
- **ObjectTrackingExperiencesSampleApp.swift**: WindowGroup과 ImmersiveSpace를 관리하는 메인 앱 진입점
- **AppModel**: 앱 전체 상태를 유지하는 Observable 클래스로, 특히 immersive space 상태(`closed`, `inTransition`, `open`)를 관리

### 주요 컴포넌트

**ImmersiveView (Views/ImmersiveView.swift)**
- 전체 객체 추적 경험을 관리하는 핵심 RealityKit 기반 AR 뷰
- 여러 엔티티를 초기화하고 관리: root, anchor, occlusion, target, scenes, labels, 인터랙티브 요소들(return key, pin)
- SwiftUI 기반 레이블을 위해 attachments와 함께 `RealityView` 사용
- 드래그(엔티티 조작)와 탭(키보드 인터랙션)을 위한 제스처 핸들러 구현
- `KeyboardGame`과 `ObjectTrackingGuide` 조정

**ObjectTrackingGuide (Utils/ObjectTrackingGuide.swift)**
- 사용자가 추적 대상 객체(Apple Magic Keyboard)를 찾도록 돕는 가이드
- 실제 객체가 감지될 때까지 사용자의 머리를 따라다니는 반투명 가이드 모델 표시
- 객체가 감지되면 가이드가 실제 객체 위에 정확히 정렬되도록 애니메이션 후 페이드 아웃
- ARKit 세션 관리: 객체 추적을 위한 `SpatialTrackingSession`과 기기 위치를 위한 `WorldTrackingProvider`

**KeyboardGame (Game/KeyboardGame.swift)**
- 인터랙티브 키보드 게임 로직 관리
- 게임 상태 트리를 정의하는 `Challenges.plist`에서 챌린지 로드
- 여러 입력 타입 지원: `anyKey`, `letter`, `word`, `keyCollision`
- 각 챌린지는 설명, 지침, 선택적 씬 이름, 새로운 챌린지로 이어지는 결과를 포함

### 엔티티 관리
- **Anchor Entity**: 추적된 물리적 객체에 앵커되는 엔티티
- **Occlusion Entity**: 키보드에 대한 오클루전 효과 제공
- **Target Entity**: 가이드 정렬을 위한 타겟 포즈를 나타냄
- **Scenes Parent**: 다양한 게임 씬 엔티티들의 컨테이너
- **Labels Parent**: SwiftUI attachment 레이블들의 컨테이너
- **Pin Entity**: 충돌 기반 인터랙션에 사용되는 드래그 가능한 핀
- **Return Key Entity**: 핀과의 충돌을 감지하는 특수 키

### RealityKit Content Package
- 위치: `Packages/RealityKitContent/`
- 모든 RealityKit 에셋(모델, 머티리얼, 텍스처, 씬)을 포함하는 Swift 패키지
- Reality Composer Pro를 사용하여 `Package.realitycomposerpro/`에서 에셋 관리
- 메인 에셋 번들: `RealityKitContent.rkassets/`
- 추적을 위한 참조 객체: `Geometry/MagicKeyboard`

### 커스텀 시스템 및 컴포넌트

**FadeOutComponent & FadeOutSystem**
- 시간 경과에 따라 엔티티를 페이드 아웃하는 커스텀 ECS 컴포넌트 및 시스템
- 객체 감지 후 가이드 엔티티를 페이드 아웃하는 데 사용
- `ImmersiveView.task` 수정자에서 등록됨

### 게임 플로우
1. 앱이 immersive space를 열음
2. `ObjectTrackingGuide`가 사용자의 머리를 따라다니는 반투명 키보드 모델을 표시
3. 사용자가 주변을 둘러보며 실제 Magic Keyboard를 찾음
4. 키보드가 감지되면 가이드가 실제 키보드와 정렬되도록 애니메이션 후 페이드 아웃
5. `KeyboardGame`이 plist에서 로드된 초기 챌린지로 시작
6. 사용자가 키를 탭하거나, 단어를 입력하거나, 핀을 리턴 키로 드래그하여 인터랙션
7. 사용자 입력에 따라 챌린지 트리를 통해 게임 진행

### ARKit 통합
- 객체 및 월드 추적 구성과 함께 `SpatialTrackingSession` 사용
- 기기 위치 쿼리를 위한 `WorldTrackingProvider` (가이드 엔티티 reparenting 시 사용)
- 객체 추적이 물리적 Magic Keyboard에 경험을 앵커함

## 개발 참고사항

### 엔티티 검색
Reality Composer Pro 씬에서 `findEntity(named:)`를 사용하여 이름으로 엔티티를 검색:
- "Anchor", "Target", "OcclusionKeyboard", "ScenesParent", "LabelsParent", "RETURN", "DELETE", "PushPin"

### 투명도 관리
코드베이스는 엔티티 표시/숨김을 위해 `OpacityComponent`를 관리하는 커스텀 `setOpacity(_:)` extension을 `Entity`에 사용합니다.

### 파티클 이미터
키에는 탭 시 활성화되는 파티클 이미터가 있습니다. 코드는 `ParticleEmitterComponent`를 통해 이미터 상태를 관리합니다.

### 챌린지 시스템
게임 플로우를 변경하려면 `Challenges.plist`를 수정하세요. 각 챌린지는 다양한 플레이어 입력에 따라 여러 결과를 가질 수 있으며, 분기하는 내러티브 구조를 생성합니다.

## 권한
앱은 환경에서 Apple Magic 키보드를 감지하기 위해 world sensing 권한(`NSWorldSensingUsageDescription`)이 필요합니다.
