import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prime/models/project.dart';
import 'package:prime/providers/project_data.dart';
import 'package:prime/providers/user_data.dart';
import 'package:prime/screens/project_details_screen.dart';
import 'package:prime/screens/add_task_screen.dart'; // Import needed for ProjectCard button
// import 'package:prime/screens/launcher_screen.dart'; // Needed only for debug reset button
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // --- Helper to show the Add Project Dialog ---
  void _showAddProjectDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    Color selectedColor = Colors.blue; // Example default color

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('پروژه جدید'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: "نام پروژه"),
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('انصراف'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            FilledButton(
              child: const Text('ایجاد'),
              onPressed: () {
                final String title = titleController.text.trim();
                if (title.isNotEmpty) {
                  Provider.of<ProjectData>(context, listen: false)
                      .addProject(title, selectedColor);
                  Navigator.of(dialogContext).pop();
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('نام پروژه نمی‌تواند خالی باشد!')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // --- Helper for Delete Project Confirmation Dialog ---
  void _showDeleteConfirmationDialog(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('حذف پروژه؟'),
        content: Text('آیا مطمئن هستید که می‌خواهید پروژه "${project.title}" و تمام تسک‌های آن را حذف کنید؟ این عمل قابل بازگشت نیست.'),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${project.title}" حذف شد.'), duration: Duration(seconds: 2)),
              );
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // --- Helper function to show Edit Project Dialog (Example) ---
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


  @override
  Widget build(BuildContext context) {
    final projectData = context.watch<ProjectData>();
    final userData = context.watch<UserData>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Builder(
        builder: (context) {
          // --- Loading State ---
          if (projectData.isLoading || userData.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Empty State ---
          if (projectData.projects.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.folder_badge_plus, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 25),
                    Text(
                      "هنوز پروژه‌ای وجود ندارد",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "برای ایجاد اولین پروژه خود، دکمه زیر را فشار دهید.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    FilledButton.icon(
                      icon: const Icon(CupertinoIcons.add),
                      label: const Text('ایجاد پروژه جدید'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      onPressed: () => _showAddProjectDialog(context),
                    ),
                    // Optional: Reset button for debugging setup flow
                    // TextButton(
                    //    onPressed: () => context.read<UserData>().resetSetup().then((_) {
                    //      if (context.mounted) { // Check mount status
                    //        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LauncherScreen()), (route) => false);
                    //      }
                    //    }),
                    //    child: Text("Reset Setup (Debug)")
                    // ),
                  ],
                ),
              ),
            );
          }

          // --- Projects List State ---
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                Provider.of<ProjectData>(context, listen: false).loadProjects(),
                // No user data refresh needed typically
              ]);
            },
            child: CustomScrollView(
              slivers: [
                // --- Header ---
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 15, // Adjust top padding
                    left: 16,
                    right: 16,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Text(
                        'سلام، ${userData.userName.isNotEmpty ? userData.userName : 'کاربر'}!',
                        style: const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              'پروژه‌های\nشما (${projectData.projects.length})',
                              style: const TextStyle(color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold, height: 1.1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          CircleAvatar(
                            radius: 33,
                            backgroundImage: userData.pfpPath.isNotEmpty
                                ? AssetImage(userData.pfpPath) as ImageProvider // Cast needed sometimes
                                : const AssetImage('assets/img/pfp/1.png'), // Fallback default PFP
                            backgroundColor: Colors.grey.shade200,
                            // Handle potential AssetImage errors more gracefully
                            onBackgroundImageError: (exception, stackTrace) {
                              print("Error loading profile picture: $exception");
                              // Consider showing a placeholder icon or color
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                    ]),
                  ),
                ),

                // --- Project Cards ---
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final project = projectData.projects[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectDetailsScreen(projectId: project.id),
                                ),
                              );
                            },
                            child: ProjectCard(
                              project: project,
                              onDelete: () => _showDeleteConfirmationDialog(context, project),
                              // Pass edit handler to ProjectCard
                              onEdit: () => _showEditProjectDialog(context, project),
                            ),
                          ),
                        );
                      },
                      childCount: projectData.projects.length,
                    ),
                  ),
                ),

                // --- Footer Add Button ---
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 25.0), // Adjust padding
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: SizedBox(
                        height: 60, // Slightly smaller add button?
                        width: double.infinity,
                        child: Material(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(30),
                          child: InkWell(
                            onTap: () => _showAddProjectDialog(context),
                            borderRadius: BorderRadius.circular(30),
                            child: const Center(
                              child: Icon(CupertinoIcons.plus, color: Colors.black54, size: 28),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


// --- ProjectCard Widget ---
// screens/home_screen.dart

// ... (کد های دیگر HomeScreen) ...

// --- ProjectCard Widget ---
class ProjectCard extends StatefulWidget {
  final Project project;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onDelete,
    this.onEdit,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> with SingleTickerProviderStateMixin {
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
    _animation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut
    );
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

  Widget _buildCircularButton({ /* ... کد این متد کمکی بدون تغییر ... */
    required IconData icon,
    required VoidCallback onTap,
    required Color iconColor,
    Color backgroundColor = Colors.transparent,
    Color? borderColor,
    String? tooltip,
    double size = 50,
    double iconSize = 25,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: borderColor != null ? Border.all(width: 1.5, color: borderColor) : null,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: Offset(0, 1)
                )
              ]
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
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

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 4,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // --- Background Image & Gradient ---
          Container(
            constraints: const BoxConstraints(minHeight: 280), // Maintain minimum height
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) { print("Error loading image: $exception"); },
              ),
            ),
            child: Container( // Gradient overlay
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.5), Colors.transparent, Colors.black.withOpacity(0.7)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: const [0.0, 0.4, 1.0]),
              ),
            ),
          ),

          // --- Content Area ---
          // Wrap the content Column in a Padding with significant bottom padding
          Padding(
            // *** تغییر اصلی اینجاست ***
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 110), // <-- افزایش bottom padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween, // <-- حذف یا تغییر این خط
              mainAxisSize: MainAxisSize.min, // <-- ستون حداقل ارتفاع لازم را بگیرد
              children: [
                // --- Project Title ---
                Text(
                  widget.project.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold,
                      height: 1.2, shadows: [Shadow(blurRadius: 3, color: Colors.black87)]),
                ),
                const SizedBox(height: 20), // Add fixed space after title

                // --- Progress Indicator Row ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Vertical Progress Bar
                    Container(
                      width: 12, height: 55,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(6)),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: progress,
                          child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Task Count Text
                    Flexible(
                      child: Text(
                        '${widget.project.completedTasksCount} / ${widget.project.totalTasksCount}\nتسک ها',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500,
                            shadows: [Shadow(blurRadius: 1, color: Colors.black54)]),
                      ),
                    ),
                  ],
                ),
                // No Spacer needed here if using Padding from parent
              ],
            ),
          ),

          // --- Action Buttons (Positioned at the absolute bottom of the Stack) ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(15.0), // Padding around the button row itself
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Expand/Collapse Button
                  _buildCircularButton(
                    icon: _isExpanded ? CupertinoIcons.xmark : CupertinoIcons.ellipsis,
                    onTap: _toggleExpanded,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    borderColor: Colors.white.withOpacity(0.6),
                    iconColor: Colors.white,
                    tooltip: _isExpanded ? 'Close Options' : 'More Options',
                  ),
                  // Animated Edit/Delete Buttons
                  FadeTransition(
                    opacity: _animation,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0.5, 0.0), end: Offset.zero).animate(_animation),
                      child: _isExpanded || _controller.isAnimating ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildCircularButton( // Edit Button
                            icon: Icons.edit_outlined,
                            onTap: () { widget.onEdit?.call(); _toggleExpanded(); },
                            backgroundColor: Colors.white.withOpacity(0.25),
                            borderColor: Colors.white.withOpacity(0.6),
                            iconColor: Colors.white, tooltip: 'Edit Project',
                          ),
                          const SizedBox(width: 10),
                          _buildCircularButton( // Delete Button
                            icon: Icons.delete_outline,
                            onTap: () { widget.onDelete(); _toggleExpanded(); },
                            backgroundColor: Colors.red.withOpacity(0.25),
                            borderColor: Colors.white.withOpacity(0.6),
                            iconColor: Colors.red[700] ?? Colors.red, tooltip: 'Delete Project',
                          ),
                        ],
                      ) : const SizedBox.shrink(),
                    ),
                  ),
                  // Add Task Button
                  _buildCircularButton(
                    icon: CupertinoIcons.plus,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) =>
                          AddTaskScreen(projectId: widget.project.id)
                      ));
                    },
                    backgroundColor: Colors.white.withOpacity(0.4),
                    iconColor: Colors.black87, tooltip: 'Add Task',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

