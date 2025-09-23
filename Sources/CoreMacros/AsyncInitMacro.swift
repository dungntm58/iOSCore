//
//  AsyncInitMacro.swift
//  CoreMacros
//
//  Public interface for AsyncInit macro
//

/// Macro for async initialization of actor properties using AsyncInit value wrapper
///
/// Usage:
/// ```swift
/// actor MyActor {
///     @AsyncInit var viewModel: SwitchViewModel?
///
///     init(viewModel: SwitchViewModel? = nil) {
///         self._viewModel = AsyncInit {
///             viewModel ?? await SwitchViewModel()
///         }
///     }
/// }
/// ```
///
/// This generates:
/// ```swift
/// private let _viewModel: AsyncInit<SwitchViewModel>
///
/// private var viewModel: SwitchViewModel {
///     get async {
///         await _viewModel.value
///     }
/// }
/// ```
@attached(accessor)
@attached(peer, names: prefixed(_))
public macro AsyncInit() = #externalMacro(module: "CoreMacrosPlugin", type: "AsyncInitMacro")