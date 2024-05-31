import 'package:agazh/agazsh_route_config.dart';
import 'package:agazh/application/auth/auth_provider.dart';
import 'package:agazh/application/auth/auth_states.dart';
import 'package:agazh/application/job/job_provider.dart';
import 'package:agazh/application/job/job_state.dart';
import 'package:agazh/application/job_application/job_application_provider.dart';
import 'package:agazh/application/job_application/job_application_state.dart';
import 'package:agazh/domain/auth/user_model.dart';
import 'package:agazh/domain/job/job_model.dart';
import 'package:agazh/domain/job_application/job_application_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FreelancerHomeScreen extends ConsumerStatefulWidget {
  const FreelancerHomeScreen({super.key});

  @override
  ConsumerState<FreelancerHomeScreen> createState() => _FreelancerHomeScreenState();
}

class _FreelancerHomeScreenState extends ConsumerState<FreelancerHomeScreen> {
  final TextEditingController coverLetterController = TextEditingController();

  @override
  void dispose() {
    coverLetterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
if (authState is AuthSuccessState) {
  Future(() {
    ref.read(jobProvider.notifier).getJobs(null); 
    ref.read(jobApplicationProvider.notifier).getMyJobApplications(Role.freelancer);
  });
}


    ref.listen<AuthState>(authProvider, (previous, state) {
      if (state is AuthIitialState) {
        context.go(PathName.logIn);
      }
    });

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                  },
                  child: const Text(
                    "Log out",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              )
            ],
          ),
        ),
        appBar: AppBar(
          title: const Text('Hello, Freelancer!'),
        ),
        body: TabBarView(
          children: [
            Consumer(
              builder: (context, ref, child) {
                final jobState = ref.watch(jobProvider);
                if (jobState is JobsLoading) {
                  return const CircularProgressIndicator();
                } else if (jobState is JobsLoadingFailed) {
                  return Text(jobState.message);
                } else if (jobState is JobsLoaded) {
                  var jobs = jobState.jobs;
                  return ListView.builder(
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () => _showApplyDialog(context, jobs[index]),
                        title: Text(jobs[index].name),
                        subtitle: Text(jobs[index].description),
                        trailing: Text(
                          "\$${jobs[index].salary.toString()}",
                        ),
                      );
                    },
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                final jobApplicationState = ref.watch(jobApplicationProvider);
                if (jobApplicationState is GetMyApplicationsLoadingState) {
                  return const CircularProgressIndicator();
                } else if (jobApplicationState is JobApplicationCreationFailed) {
                  return Text(jobApplicationState.message);
                } else if (jobApplicationState is JobApplicationSuccess) {
                  var myApplications = jobApplicationState.jobApplications;
                  return ListView.builder(
                    itemCount: myApplications.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () => _showUpdateApplicationDialog(
                          context,
                          myApplications[index],
                        ),
                        title: Text(myApplications[index].name),
                        subtitle: Text(myApplications[index].description),
                        trailing: SizedBox(
                          width: 120,
                          child: Row(
                            children: [
                              Text(
                                myApplications[index].status.toString().split('.').last,
                              ),
                              IconButton(
                                onPressed: () {
                                  ref.read(jobApplicationProvider.notifier).deleteApplication(myApplications[index]);
                                },
                                icon: const Icon(Icons.delete),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ],
        ),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(
              text: 'Explore Jobs',
            ),
            Tab(
              text: 'My Applications',
            ),
          ],
        ),
      ),
    );
  }

  void _showApplyDialog(BuildContext context, Job job) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Apply for job'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Cover letter'),
            controller: coverLetterController,
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(jobApplicationProvider.notifier).createApplication(job, coverLetterController.text);
                context.pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateApplicationDialog(BuildContext context, JobApplication myApplication) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Application'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Cover letter'),
            controller: coverLetterController..text = myApplication.description,
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(jobApplicationProvider.notifier).updateApplication(
                  myApplication..description = coverLetterController.text,
                );
                context.pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
