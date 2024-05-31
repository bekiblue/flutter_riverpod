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

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  _ClientHomeScreenState createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  late JobStatus dropDownValue;

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController salaryController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    if (authState is AuthSuccessState) {
      final me = authState.user;
      Future(() {
        ref.read(jobProvider.notifier).getJobs(me.id);
        ref
            .read(jobApplicationProvider.notifier)
            .getMyJobApplications(Role.client);
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
        appBar: AppBar(title: const Text('Hello, Client!')),
        body: TabBarView(
          children: [
            Consumer(
              builder: (context, ref, child) {
                final jobApplicationState = ref.watch(jobApplicationProvider);
                if (jobApplicationState is GetMyApplicationsLoadingState) {
                  return const CircularProgressIndicator();
                } else if (jobApplicationState
                    is JobApplicationCreationFailed) {
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
                        trailing: Text(
                          myApplications[index]
                              .status
                              .toString()
                              .split('.')
                              .last,
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
                        onTap: () => _showUpdateJobDialog(context, jobs[index]),
                        title: Text(
                          "${jobs[index].name} - ${jobs[index].status.toString().split('.').last}",
                        ),
                        subtitle: Text(jobs[index].description),
                        trailing: SizedBox(
                          width: 120,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "\$${jobs[index].salary.toString()}",
                              ),
                              IconButton(
                                onPressed: () {
                                  ref
                                      .read(jobProvider.notifier)
                                      .deleteJob(jobs[index]);
                                },
                                icon: Icon(Icons.delete),
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
              text: 'Applications',
            ),
            Tab(
              text: 'My jobs',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showCreateJobDialog(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  _showUpdateJobDialog(BuildContext context, Job job) {
    setState(() {
      dropDownValue = job.status;
    });
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(job.name),
            content: DropdownButton(
              value: dropDownValue,
              items: const [
                DropdownMenuItem(
                  value: JobStatus.open,
                  child: Text("Open"),
                ),
                DropdownMenuItem(
                  value: JobStatus.closed,
                  child: Text("Closed"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  dropDownValue = value!;
                });
              },
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(jobProvider.notifier)
                      .updateJob(job..status = dropDownValue);
                  context.pop();
                },
                child: const Text("Update"),
              ),
            ],
          );
        });
      },
    );
  }

  void _showCreateJobDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create job'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: salaryController,
                decoration: const InputDecoration(labelText: 'Salary'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                clearInputs();
                context.pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!validateInputs()) {
                  // show snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                    ),
                  );
                  return;
                }
                var me = (ref.read(authProvider) as AuthSuccessState).user;
                ref.read(jobProvider.notifier).createJob(
                      Job(
                        author: me.id,
                        name: nameController.text,
                        description: descriptionController.text,
                        salary: salaryController.text,
                        status: JobStatus.open,
                      ),
                    );
                clearInputs();
                context.pop();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  bool validateInputs() {
    return nameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        salaryController.text.isNotEmpty;
  }

  void clearInputs() {
    nameController.clear();
    descriptionController.clear();
    salaryController.clear();
  }

  _showUpdateApplicationDialog(
      BuildContext context, JobApplication myApplication) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Update Application'),
            content: DropdownButton(
              value: myApplication.status,
              items: const [
                DropdownMenuItem(
                  child: Text('Pending'),
                  value: JobApplicationStatus.pending,
                ),
                DropdownMenuItem(
                  child: Text('Accepted'),
                  value: JobApplicationStatus.accepted,
                ),
                DropdownMenuItem(
                  child: Text('Rejected'),
                  value: JobApplicationStatus.rejected,
                ),
              ],
              onChanged: (value) {
                setState(() {
                  myApplication.status = value!;
                });
              },
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
                  ref
                      .read(jobApplicationProvider.notifier)
                      .updateApplication(myApplication);
                  context.pop();
                },
                child: const Text('Update'),
              ),
            ],
          );
        });
      },
    );
  }
}
