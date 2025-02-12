import 'package:flutter/material.dart';

class MvcController with ChangeNotifier {
  @mustCallSuper
  void initState(BuildContext context) {}

  void refreshView() {
    notifyListeners();
  }

  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
  }

  @mustCallSuper
  void didChangeDependencies() {}

  @mustCallSuper
  void didUpdateWidget(covariant MvcView<MvcController> oldWidget) {}
}

class MvcContextController extends MvcController {
  late BuildContext context;

  @override
  @mustCallSuper
  void initState(BuildContext context) {
    super.initState(context);
    this.context = context;
  }
}

class MvcView<T extends MvcController> extends StatefulWidget {
  final T controller;

  const MvcView({super.key, required this.controller});

  @override
  State<MvcView> createState() => _MvcViewState();

  Widget build(BuildContext context) {
    return Container();
  }
}

class _MvcViewState extends State<MvcView> {
  @override
  void initState() {
    super.initState();
    widget.controller.initState(context);
    widget.controller.addListener(refresh);
  }

  void refresh() {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant MvcView<MvcController> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller.didUpdateWidget(oldWidget);

    oldWidget.controller.removeListener(refresh);
    widget.controller.addListener(refresh);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(refresh);
    widget.controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context);
  }
}
