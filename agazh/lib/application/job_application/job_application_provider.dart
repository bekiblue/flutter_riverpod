import 'package:agazh/application/auth/auth_provider.dart';
import 'package:agazh/application/auth/auth_states.dart';
import 'package:agazh/application/job_application/job_application_state.dart';
import 'package:agazh/domain/auth/user_model.dart';
import 'package:agazh/domain/job/job_model.dart';
import 'package:agazh/domain/job_application/job_application_model.dart';
import 'package:agazh/infrastructure/auth/auth_repository.dart';
import 'package:agazh/infrastructure/job_application/job_application_repositrory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobApplicationNotifier extends StateNotifier<JobApplicationState> {
  final Ref ref;

  JobApplicationNotifier(this.ref) : super(JobApplicationInitial());

  Future<void> createApplication(Job job, String coverLetter) async {
    try {
      state = JobApplicationCreationLoading();
      var prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token');
      var me = await AuthRepository().getMe(token!);
      final jobApplication = JobApplication(
        job: job.id,
        description: coverLetter,
        applicant: me.id,
        name: 'application for ${job.name}',
        status: JobApplicationStatus.pending,
      );
      await JobApplicationRepository().createJobApplication(jobApplication);
      var myApplications = await JobApplicationRepository()
          .getMyApplications((ref.read(authProvider) as AuthSuccessState).user.role);
      state = JobApplicationSuccess(jobApplications: myApplications);
    } catch (e) {
      state = JobApplicationCreationFailed(
        message: e.toString(),
        jobApplications: await JobApplicationRepository()
            .getMyApplications((ref.read(authProvider) as AuthSuccessState).user.role),
      );
    }
  }

  Future<void> getMyJobApplications(Role forRole) async {
    try {
      state = GetMyApplicationsLoadingState();
      var myApplications = await JobApplicationRepository().getMyApplications(forRole);
      state = JobApplicationSuccess(jobApplications: myApplications);
    } catch (e) {
      state = JobApplicationCreationFailed(message: e.toString(), jobApplications: const []);
    }
  }

  Future<void> updateApplication(JobApplication application) async {
    try {
      state = GetMyApplicationsLoadingState();
      await JobApplicationRepository().updateApplication(application);
      var myApplications = await JobApplicationRepository()
          .getMyApplications((ref.read(authProvider) as AuthSuccessState).user.role);
      state = JobApplicationSuccess(jobApplications: myApplications);
    } catch (e) {
      state = JobApplicationCreationFailed(
        message: e.toString(),
        jobApplications: await JobApplicationRepository()
            .getMyApplications((ref.read(authProvider) as AuthSuccessState).user.role),
      );
    }
  }

  Future<void> deleteApplication(JobApplication application) async {
    try {
      state = GetMyApplicationsLoadingState();
      await JobApplicationRepository().deleteApplication(application);
      var myApplications = await JobApplicationRepository()
          .getMyApplications((ref.read(authProvider) as AuthSuccessState).user.role);
      state = JobApplicationSuccess(jobApplications: myApplications);
    } catch (e) {
      state = JobApplicationCreationFailed(
        message: e.toString(),
        jobApplications: await JobApplicationRepository()
            .getMyApplications((ref.read(authProvider) as AuthSuccessState).user.role),
      );
    }
  }
}

final jobApplicationProvider = StateNotifierProvider<JobApplicationNotifier, JobApplicationState>((ref) {
  return JobApplicationNotifier(ref);
});
