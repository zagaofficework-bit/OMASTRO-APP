import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/example_bloc.dart';
import '../bloc/example_event.dart';
import '../bloc/example_state.dart';

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the Bloc to the widget tree
    return BlocProvider(
      create: (context) => ExampleBloc(),
      child: const ExampleView(),
    );
  }
}

class ExampleView extends StatelessWidget {
  const ExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bloc Clean Architecture Example')),
      body: Center(
        // BlocBuilder rebuilds the UI when the state changes
        child: BlocBuilder<ExampleBloc, ExampleState>(
          builder: (context, state) {
            if (state is ExampleInitial) {
              return const Text('Press the button to load data.');
            } else if (state is ExampleLoading) {
              return const CircularProgressIndicator();
            } else if (state is ExampleLoaded) {
              return Text(
                state.data,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              );
            } else if (state is ExampleError) {
              return Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Trigger an event on the bloc
          context.read<ExampleBloc>().add(LoadExampleData());
        },
        child: const Icon(Icons.download),
      ),
    );
  }
}
