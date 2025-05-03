import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prime/models/task.dart' as model;
import 'package:prime/providers/project_data.dart';
import 'package:prime/providers/user_data.dart'; // Import UserData if needed for header customization
import 'package:prime/screens/add_task_screen.dart';
import 'package:prime/providers/task_provider.dart';

import '../models/project.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final String projectId;

  const ProjectDetailsScreen({
    super.key,
    required this.projectId,
  });

  // --- Helper function to show Delete Task Confirmation ---
  void _showDeleteTaskConfirmation(BuildContext context, ProjectData projectData, model.Task task) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
            title: const Text("حذف تسک؟"),
            content: Text('آیا مطمئن هستید که می‌خواهید تسک "${task.description}" را حذف کنید؟'),
            actions: [
              TextButton(onPressed: ()=> Navigator.of(ctx).pop(), child: const Text("انصراف")),
              TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () {
                    projectData.deleteTask(projectId, task.id);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text("حذف")
              ),
            ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer for ProjectData
    return Consumer<ProjectData>(
      builder: (context, projectData, child) {
        final project = projectData.findProjectById(projectId);

        // --- Handle Project Not Found ---
        if (project == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('پروژه یافت نشد.')),
              );
            }
          });
          return const Scaffold(
            body: Center(child: Text("پروژه یافت نشد...")),
          );
        }

        // --- Build UI ---
        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              // --- Project Header ---
              SliverToBoxAdapter(
                child: ProjectDetailsHeader(project: project),
              ),

              // --- Task List Title ---
              SliverPadding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 25.0, bottom: 10.0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تسک‌ها (${project.tasks.where((t) => !t.isDone).length} باقی‌مانده)',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      // Optional: Add filter/sort button here
                    ],
                  ),
                ),
              ),

              // --- Task List or Empty State ---
              if (project.tasks.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.list_bullet, size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 15),
                          Text(
                            'هنوز تسکی وجود ندارد',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'برای اضافه کردن اولین تسک، دکمه + را فشار دهید.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final task = project.tasks[index];
                        return TodoItem(
                          task: task,
                          projectId: project.id,
                          // Pass the delete confirmation helper
                          onDeleteRequested: () => _showDeleteTaskConfirmation(context, projectData, task),
                        );
                      },
                      childCount: project.tasks.length,
                    ),
                  ),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80.0)), // Bottom spacing
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddTaskScreen(projectId: project.id)));
            },
            backgroundColor: project.color, // Use project color
            foregroundColor: Colors.white,
            tooltip: 'افزودن تسک جدید',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}


// --- ProjectDetailsHeader Widget ---
class ProjectDetailsHeader extends StatefulWidget {
  final Project project;

  const ProjectDetailsHeader({super.key, required this.project});

  @override
  State<ProjectDetailsHeader> createState() => _ProjectDetailsHeaderState();
}

class _ProjectDetailsHeaderState extends State<ProjectDetailsHeader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('حذف پروژه؟'),
        content: Text('آیا مطمئن هستید که می‌خواهید پروژه "${project.title}" و تمام تسک‌های آن را حذف کنید؟'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('انصراف'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<ProjectData>().deleteProject(project.id);
              Navigator.of(ctx).pop();
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${project.title}" حذف شد.')),
                );
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showEditProjectDialog(BuildContext context, Project project) {
    final titleController = TextEditingController(text: project.title);
    showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text("ویرایش پروژه"),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: "نام پروژه"),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text("انصراف")),
            FilledButton(
                onPressed: () {
                  final newTitle = titleController.text.trim();
                  if (newTitle.isNotEmpty) {
                    context.read<ProjectData>().updateProjectDetails(project.id, newTitle: newTitle);
                    Navigator.of(dialogCtx).pop();
                  } else {
                    ScaffoldMessenger.of(dialogCtx).showSnackBar(
                      const SnackBar(content: Text('نام پروژه نمی‌تواند خالی باشد!')),
                    );
                  }
                },
                child: const Text("ذخیره تغییرات")
            ),
          ],
        )
    );
  }

  Widget _buildHeaderActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color backgroundColor = const Color(0x55FFFFFF),
    Color iconColor = Colors.white,
    double size = 45,
    double iconSize = 22,
    Border? border,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle, border: border),
          child: Icon(icon, color: iconColor, size: iconSize),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.project.totalTasksCount > 0
        ? widget.project.completedTasksCount / widget.project.totalTasksCount
        : 0.0;
    String imagePath = widget.project.imagePath;

    return SafeArea(
      top: false, bottom: false,
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30),
            )
        ),
        elevation: 0, clipBehavior: Clip.antiAlias, margin: EdgeInsets.zero,
        child: Stack(
          children: [
            Container(
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.3),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath), fit: BoxFit.cover,
                  onError: (exception, stackTrace) { print("Error loading image: $exception"); },
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.5), Colors.transparent, Colors.black.withOpacity(0.7)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0.0, 0.5, 1.0]),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 20, right: 20, bottom: 20
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeaderActionButton(
                          icon: CupertinoIcons.back,
                          onPressed: () => Navigator.pop(context),
                          tooltip: 'Back',
                          backgroundColor: Colors.white.withOpacity(0.25),
                          border: Border.all(width: 1, color: Colors.white.withOpacity(0.4)),
                        ),
                        _buildHeaderActionButton(
                          icon: _isExpanded ? CupertinoIcons.xmark : CupertinoIcons.ellipsis,
                          onPressed: _toggleExpanded,
                          tooltip: _isExpanded ? 'Close Options' : 'Project Options',
                          backgroundColor: Colors.white.withOpacity(0.25),
                          border: Border.all(width: 1, color: Colors.white.withOpacity(0.4)),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.project.title, maxLines: 3, overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.09,
                              fontWeight: FontWeight.bold, height: 1.15,
                              shadows: const [Shadow(blurRadius: 4, color: Colors.black)]),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 12, height: 60,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(6)),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                    heightFactor: progress,
                                    child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)))),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                '${widget.project.completedTasksCount} / ${widget.project.totalTasksCount} تسک انجام شده',
                                style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.04,
                                    fontWeight: FontWeight.w500, shadows: const [Shadow(blurRadius: 1, color: Colors.black54)]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10 + 50, right: 20,
              child: FadeTransition(
                opacity: _animation,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0.3, 0.0), end: Offset.zero).animate(_animation),
                  child: _isExpanded || _controller.isAnimating ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                    child: IntrinsicWidth(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                            tooltip: 'Edit Project', visualDensity: VisualDensity.compact,
                            onPressed: () { _showEditProjectDialog(context, widget.project); _toggleExpanded(); },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            tooltip: 'Delete Project', visualDensity: VisualDensity.compact,
                            onPressed: () { _showDeleteConfirmation(context, widget.project); _toggleExpanded(); },
                          ),
                        ],
                      ),
                    ),
                  ) : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// --- TodoItem Widget ---
class TodoItem extends StatelessWidget {
  final model.Task task;
  final String projectId;
  final VoidCallback onDeleteRequested;

  const TodoItem({
    super.key,
    required this.task,
    required this.projectId,
    required this.onDeleteRequested,
  });

  @override
  Widget build(BuildContext context) {
    final projectData = context.read<ProjectData>();

    return InkWell(
      onTap: () {
        projectData.toggleTaskCompletion(projectId, task.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
        child: Row(
          children: [
            Icon(
              task.isDone ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
              color: task.isDone ? Colors.green : Colors.grey.shade400,
              size: 26,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.description,
                    maxLines: 3, overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 17,
                        decoration: task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                        color: task.isDone ? Colors.grey.shade500 : Colors.black87,
                        fontWeight: task.isDone ? FontWeight.normal : FontWeight.w500,
                        height: 1.3
                    ),
                  ),
                  if (task.date.isNotEmpty && task.date != 'No Date')
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        task.date,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.grey.shade400, size: 22),
              tooltip: 'Delete Task', splashRadius: 20, visualDensity: VisualDensity.compact,
              onPressed: onDeleteRequested,
            ),
          ],
        ),
      ),
    );
  }
}