import 'package:agazh/application/auth/auth_provider.dart';
import 'package:agazh/application/auth/auth_states.dart';
import 'package:agazh/application/job/job_state.dart';
import 'package:agazh/domain/job/job_model.dart';
import 'package:agazh/infrastructure/job/job_repositrory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JobNotifier extends StateNotifier<JobState> {
  final Ref ref;
  final JobRepository jobRepository;

  JobNotifier(this.ref, this.jobRepository) : super(JobInitial());

  Future<void> getJobs(int? authorId) async {
    try {
      state = JobsLoading();
      final List<Job> jobs = await jobRepository.getJobs(authorId);
      state = JobsLoaded(jobs);
    } catch (e) {
      state = JobsLoadingFailed(e.toString());
    }
  }

  Future<void> createJob(Job job) async {
    try {
      state = JobsLoading();
      await jobRepository.createJob(job);
      var me = (ref.read(authProvider) as AuthSuccessState).user;
      final List<Job> jobs = await jobRepository.getJobs(me.id);
      state = JobsLoaded(jobs);
    } catch (e) {
      state = JobsLoadingFailed(e.toString());
    }
  }

  Future<void> updateJob(Job job) async {
    try {
      state = JobsLoading();
      await jobRepository.updateJob(job);
      var me = (ref.read(authProvider) as AuthSuccessState).user;
      final List<Job> jobs = await jobRepository.getJobs(me.id);
      state = JobsLoaded(jobs);
    } catch (e) {
      state = JobsLoadingFailed(e.toString());
    }
  }

  Future<void> deleteJob(Job job) async {
    try {
      state = JobsLoading();
      await jobRepository.deleteJob(job);
      var me = (ref.read(authProvider) as AuthSuccessState).user;
      final List<Job> jobs = await jobRepository.getJobs(me.id);
      state = JobsLoaded(jobs);
    } catch (e) {
      state = JobsLoadingFailed(e.toString());
    }
  }
}

final jobProvider = StateNotifierProvider<JobNotifier, JobState>((ref) {
  return JobNotifier(ref, JobRepository());
});
