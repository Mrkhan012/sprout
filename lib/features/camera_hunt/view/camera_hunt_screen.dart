import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/hunt_item.dart';
import '../../../data/models/reward.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/bouncy_tap.dart';
import '../../../shared/widgets/celebration_overlay.dart';
import '../../../shared/widgets/gradient_scaffold.dart';
import '../../../shared/widgets/pill.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../rewards/viewmodel/rewards_cubit.dart';
import '../viewmodel/camera_hunt_bloc.dart';
import '../viewmodel/camera_hunt_event.dart';
import '../viewmodel/camera_hunt_state.dart';

/// Task 4 — a live camera learning activity. The child finds & snaps five real
/// things, tags each with a friendly label, and earns the Explorer sticker.
class CameraHuntScreen extends StatelessWidget {
  const CameraHuntScreen({super.key});

  static const _reward = Reward(
    id: 'nature_explorer',
    label: 'Nature Explorer',
    emoji: '🔭',
    color: AppColors.teal,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CameraHuntBloc(const ActivityRepository())
        ..add(const HuntStarted()),
      child: BlocListener<CameraHuntBloc, CameraHuntState>(
        listenWhen: (prev, curr) =>
            prev.status != HuntStatus.complete &&
            curr.status == HuntStatus.complete,
        listener: (context, _) => context.read<RewardsCubit>().award(_reward),
        child: const _CameraHuntView(),
      ),
    );
  }
}

class _CameraHuntView extends StatefulWidget {
  const _CameraHuntView();

  @override
  State<_CameraHuntView> createState() => _CameraHuntViewState();
}

class _CameraHuntViewState extends State<_CameraHuntView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    final bloc = context.read<CameraHuntBloc>();
    if (lifecycle == AppLifecycleState.inactive ||
        lifecycle == AppLifecycleState.paused) {
      bloc.add(const HuntPaused());
    } else if (lifecycle == AppLifecycleState.resumed) {
      bloc.add(const HuntResumed());
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return GradientScaffold(
      blobs: false,
      padding:
          EdgeInsets.symmetric(horizontal: r.scale(16), vertical: r.scale(8)),
      child: BlocBuilder<CameraHuntBloc, CameraHuntState>(
        builder: (context, state) {
          return switch (state.status) {
            HuntStatus.initializing => const _CenteredMessage(
                emoji: '📷',
                title: 'Warming up the camera…',
                showSpinner: true,
              ),
            HuntStatus.permissionDenied => _CenteredMessage(
                emoji: '🔒',
                title: AppStrings.huntPermissionTitle,
                body: AppStrings.huntPermissionBody,
                actionLabel: 'Try again',
                onAction: () =>
                    context.read<CameraHuntBloc>().add(const HuntStarted()),
              ),
            HuntStatus.error => _CenteredMessage(
                emoji: '😕',
                title: 'Oops!',
                body: state.errorMessage ?? 'Something went wrong.',
                actionLabel: 'Try again',
                onAction: () =>
                    context.read<CameraHuntBloc>().add(const HuntStarted()),
              ),
            _ => _HuntContent(state: state),
          };
        },
      ),
    );
  }
}

class _HuntContent extends StatelessWidget {
  const _HuntContent({required this.state});

  final CameraHuntState state;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final target = state.currentTarget;

    return Stack(
      children: [
        Column(
          children: [
            _TopBar(),
            SizedBox(height: r.scale(12)),
            _TargetsStrip(state: state),
            SizedBox(height: r.scale(12)),
            if (state.status != HuntStatus.complete && target != null)
              _Prompt(target: target, found: state.foundCount, total: state.total),
            SizedBox(height: r.scale(12)),
            Expanded(child: _Viewfinder(state: state)),
            SizedBox(height: r.scale(12)),
            _Controls(state: state),
            SizedBox(height: r.scale(4)),
          ],
        ),
        if (state.status == HuntStatus.complete)
          Positioned.fill(
            child: CelebrationOverlay(
              emoji: '🏆',
              title: AppStrings.huntDone,
              message: 'You found all 5! You earned the Nature Explorer sticker.',
              accent: AppColors.teal,
              buttonLabel: 'Hunt again',
              onButton: () =>
                  context.read<CameraHuntBloc>().add(const HuntReset()),
              secondaryLabel: 'Back home',
              onSecondary: () => Navigator.of(context)
                  .popUntil(ModalRoute.withName(AppRoutes.home)),
            ),
          ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        AppBackButton(),
        Spacer(),
        Pill(
          text: AppStrings.huntGoal,
          background: AppColors.teal,
          foreground: AppColors.navy,
          icon: Icons.travel_explore_rounded,
        ),
        Spacer(),
        SizedBox(width: 48),
      ],
    );
  }
}

class _Prompt extends StatelessWidget {
  const _Prompt({required this.target, required this.found, required this.total});

  final HuntItem target;
  final int found;
  final int total;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return Column(
      children: [
        Text(
          'Find ${found + 1} of $total',
          style: AppTextStyles.label(color: AppColors.onDarkSoft, size: r.font(12)),
        ),
        SizedBox(height: r.scale(4)),
        Text(
          '${target.emoji}  ${target.label}',
          textAlign: TextAlign.center,
          style: AppTextStyles.heading(color: AppColors.onDark, size: r.font(24)),
        ),
      ],
    );
  }
}

class _TargetsStrip extends StatelessWidget {
  const _TargetsStrip({required this.state});

  final CameraHuntState state;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < state.items.length; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.scale(4)),
            child: _TargetChip(
              item: state.items[i],
              active: i == state.currentIndex &&
                  state.status != HuntStatus.complete,
            ),
          ),
      ],
    );
  }
}

class _TargetChip extends StatelessWidget {
  const _TargetChip({required this.item, required this.active});

  final HuntItem item;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final size = r.scale(48);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: item.isFound
            ? AppColors.teal.withValues(alpha: 0.25)
            : AppColors.onDark.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(r.scale(14)),
        border: Border.all(
          color: active ? AppColors.gold : Colors.transparent,
          width: 2.5,
        ),
      ),
      alignment: Alignment.center,
      child: item.isFound
          ? const Icon(Icons.check_circle_rounded, color: AppColors.teal)
          : Text(item.emoji, style: TextStyle(fontSize: r.font(22))),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder({required this.state});

  final CameraHuntState state;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final controller = context.read<CameraHuntBloc>().controller;
    final radius = BorderRadius.circular(r.scale(28));

    final showingPhoto = (state.status == HuntStatus.captured ||
            state.status == HuntStatus.recognizing) &&
        state.capturedPhoto != null;

    Widget content;
    if (showingPhoto) {
      content = Image.memory(state.capturedPhoto!, fit: BoxFit.cover);
    } else if (controller != null && controller.value.isInitialized) {
      content = _CameraCover(controller: controller);
    } else {
      content = const Center(
        child: CircularProgressIndicator(color: AppColors.teal),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: AppColors.navyDeep),
          content,
          // "Looking…" scrim while the on-device model identifies the photo.
          if (state.status == HuntStatus.recognizing)
            const _RecognizingScrim(),
          // Viewfinder frame.
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: AppColors.onDark.withValues(alpha: 0.6),
                  width: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fills the viewfinder with the live preview while preserving aspect ratio.
class _CameraCover extends StatelessWidget {
  const _CameraCover({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxWidth / controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
        );
      },
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.state});

  final CameraHuntState state;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      HuntStatus.recognizing => const _RecognizingBar(),
      HuntStatus.captured => _ResultPanel(state: state),
      _ => PrimaryButton(
          label: AppStrings.huntCta,
          icon: Icons.photo_camera_rounded,
          color: AppColors.gold,
          foreground: AppColors.navy,
          expand: true,
          onPressed: state.status == HuntStatus.ready
              ? () =>
                  context.read<CameraHuntBloc>().add(const HuntPhotoCaptured())
              : null,
        ),
    };
  }
}

/// A translucent "Looking…" overlay shown over the frozen snapshot while the
/// on-device model runs.
class _RecognizingScrim extends StatelessWidget {
  const _RecognizingScrim();

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return ColoredBox(
      color: AppColors.navyDeep.withValues(alpha: 0.45),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.teal),
            SizedBox(height: r.scale(14)),
            Text(
              AppStrings.huntLooking,
              style:
                  AppTextStyles.title(color: AppColors.onDark, size: r.font(18)),
            ),
          ],
        ),
      ),
    );
  }
}

/// The control-row twin of the scrim: keeps the layout height stable while the
/// model thinks, instead of jumping between the snap button and the result.
class _RecognizingBar extends StatelessWidget {
  const _RecognizingBar();

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: r.scale(20),
          height: r.scale(20),
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.teal,
          ),
        ),
        SizedBox(width: r.scale(12)),
        Text(
          AppStrings.huntLooking,
          style: AppTextStyles.body(color: AppColors.onDarkSoft, size: r.font(15)),
        ),
      ],
    );
  }
}

/// Shows the model's best guess ("I spy a 🌸 Flower!") with a confirm button
/// and runner-up guesses. If the model couldn't tell, falls back to letting the
/// child name it via [_LabelPicker].
class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.state});

  final CameraHuntState state;

  @override
  Widget build(BuildContext context) {
    final top = state.topResult;
    if (top == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: context.r.scale(6)),
            child: Text(
              AppStrings.huntNotSure,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(
                color: AppColors.onDarkSoft,
                size: context.r.font(14),
              ),
            ),
          ),
          _LabelPicker(state: state),
        ],
      );
    }

    final r = context.r;
    final bloc = context.read<CameraHuntBloc>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.huntResultTitle,
          style: AppTextStyles.label(color: AppColors.onDarkSoft, size: r.font(12)),
        ),
        SizedBox(height: r.scale(8)),
        Text(
          '${top.emoji}  ${top.label}',
          textAlign: TextAlign.center,
          style: AppTextStyles.heading(color: AppColors.onDark, size: r.font(28)),
        ),
        SizedBox(height: r.scale(10)),
        Pill(
          text: "I'm ${top.confidencePercent}% sure!",
          background: AppColors.teal,
          foreground: AppColors.navy,
          icon: Icons.auto_awesome_rounded,
        ),
        SizedBox(height: r.scale(14)),
        PrimaryButton(
          label: AppStrings.huntConfirmCta,
          icon: Icons.check_rounded,
          color: AppColors.gold,
          foreground: AppColors.navy,
          expand: true,
          onPressed: () => bloc.add(HuntLabelSelected(top.display)),
        ),
        if (state.otherResults.isNotEmpty) ...[
          SizedBox(height: r.scale(12)),
          Text(
            AppStrings.huntMaybe,
            style:
                AppTextStyles.label(color: AppColors.onDarkSoft, size: r.font(11)),
          ),
          SizedBox(height: r.scale(8)),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: r.scale(8),
            runSpacing: r.scale(8),
            children: [
              for (final guess in state.otherResults)
                _GuessChip(
                  label: '${guess.emoji} ${guess.label}',
                  onTap: () => bloc.add(HuntLabelSelected(guess.display)),
                ),
            ],
          ),
        ],
        SizedBox(height: r.scale(8)),
        TextButton.icon(
          onPressed: () => bloc.add(const HuntRetake()),
          icon: const Icon(Icons.refresh_rounded, color: AppColors.onDarkSoft),
          label: Text(
            'Retake',
            style: AppTextStyles.button(
              color: AppColors.onDarkSoft,
              size: r.font(15),
            ),
          ),
        ),
      ],
    );
  }
}

/// A small tappable "or maybe…" alternative-guess chip.
class _GuessChip extends StatelessWidget {
  const _GuessChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return BouncyTap(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: r.scale(14),
          vertical: r.scale(9),
        ),
        decoration: BoxDecoration(
          color: AppColors.onDark.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(r.scale(16)),
          border: Border.all(color: AppColors.onDark.withValues(alpha: 0.18)),
        ),
        child: Text(
          label,
          style: AppTextStyles.body(color: AppColors.onDark, size: r.font(14)),
        ),
      ),
    );
  }
}

class _LabelPicker extends StatelessWidget {
  const _LabelPicker({required this.state});

  final CameraHuntState state;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final choices = context.read<CameraHuntBloc>().labelChoices;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppStrings.huntPickLabel,
          style: AppTextStyles.title(color: AppColors.onDark, size: r.font(18)),
        ),
        SizedBox(height: r.scale(10)),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: r.scale(8),
          runSpacing: r.scale(8),
          children: [
            for (final choice in choices)
              BouncyTap(
                onTap: () => context
                    .read<CameraHuntBloc>()
                    .add(HuntLabelSelected(choice)),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.scale(14),
                    vertical: r.scale(10),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.onDark.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(r.scale(16)),
                    border: Border.all(
                      color: AppColors.onDark.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    choice,
                    style: AppTextStyles.body(
                      color: AppColors.onDark,
                      size: r.font(14),
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: r.scale(8)),
        TextButton.icon(
          onPressed: () =>
              context.read<CameraHuntBloc>().add(const HuntRetake()),
          icon: const Icon(Icons.refresh_rounded, color: AppColors.onDarkSoft),
          label: Text(
            'Retake',
            style: AppTextStyles.button(
              color: AppColors.onDarkSoft,
              size: r.font(15),
            ),
          ),
        ),
      ],
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.emoji,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    this.showSpinner = false,
  });

  final String emoji;
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.scale(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: r.font(64))),
            SizedBox(height: r.scale(16)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.heading(color: AppColors.onDark, size: r.font(24)),
            ),
            if (body != null) ...[
              SizedBox(height: r.scale(10)),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body(color: AppColors.onDarkSoft, size: r.font(15)),
              ),
            ],
            if (showSpinner) ...[
              SizedBox(height: r.scale(24)),
              const CircularProgressIndicator(color: AppColors.teal),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: r.scale(24)),
              PrimaryButton(
                label: actionLabel!,
                icon: Icons.refresh_rounded,
                color: AppColors.teal,
                foreground: AppColors.navy,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
