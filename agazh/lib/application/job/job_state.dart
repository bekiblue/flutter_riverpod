
import 'package:agazh/domain/job/job_model.dart';

sealed class JobState {}

final class JobInitial extends JobState {}


final class JobsLoading extends JobState {}


final class JobsLoaded extends JobState {
  final List<Job> jobs;

  JobsLoaded(this.jobs);
}

final class JobsLoadingFailed extends JobState {
  final String message;

  JobsLoadingFailed(this.message);
}