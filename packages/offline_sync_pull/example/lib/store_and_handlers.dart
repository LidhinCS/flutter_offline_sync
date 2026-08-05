import 'package:offline_sync_pull/offline_sync_pull.dart';
final documentPages = <List<String>>[
  ['Doc A', 'Doc B', 'Doc C'],
  ['Doc D', 'Doc E'],
  ['Doc F'],
];

/// Simulated workflow list pages.
final workflowListPages = <List<String>>[
  ['Workflow 1', 'Workflow 2', 'Workflow 3'],
  ['Workflow 4'],
];

/// Local read model — in a real app this would be your AppDatabase (Drift).
class ExampleStore {
  final List<String> documents = [];
  final Map<String, String> workflowDetails = {};
  final Set<String> workflowsMissingDetail = {};

  void upsertDocuments(List<String> titles) {
    for (final title in titles) {
      if (!documents.contains(title)) {
        documents.add(title);
      }
    }
  }

  void upsertWorkflowList(List<String> titles) {
    for (final title in titles) {
      workflowsMissingDetail.add(title);
    }
  }

  void upsertWorkflowDetail(String title, String detail) {
    workflowDetails[title] = detail;
    workflowsMissingDetail.remove(title);
  }

  Future<List<String>> idsMissingWorkflowDetail(PullContext ctx) async {
    return workflowsMissingDetail.toList();
  }
}

/// Fake API: paginated document list.
class DocumentListPullHandler extends PullStepHandler {
  DocumentListPullHandler(this.store);

  final ExampleStore store;

  @override
  Future<PullStepResult> fetch(PullContext ctx) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = ctx.page - 1;
    if (index >= documentPages.length) {
      return const PullStepResult.success(hasMore: false);
    }

    store.upsertDocuments(documentPages[index]);
    final hasMore = index < documentPages.length - 1;
    return PullStepResult.success(hasMore: hasMore);
  }
}

/// Fake API: paginated workflow list.
class WorkflowListPullHandler extends PullStepHandler {
  WorkflowListPullHandler(this.store);

  final ExampleStore store;

  @override
  Future<PullStepResult> fetch(PullContext ctx) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = ctx.page - 1;
    if (index >= workflowListPages.length) {
      return const PullStepResult.success(hasMore: false);
    }

    store.upsertWorkflowList(workflowListPages[index]);
    final hasMore = index < workflowListPages.length - 1;
    return PullStepResult.success(hasMore: hasMore);
  }
}

/// Fake API: workflow detail per id (entity batch).
class WorkflowDetailPullHandler extends PullStepHandler {
  WorkflowDetailPullHandler(this.store);

  final ExampleStore store;

  @override
  Future<PullStepResult> fetch(PullContext ctx) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    for (final title in ctx.entityIds) {
      store.upsertWorkflowDetail(title, 'Detail for $title');
    }
    return const PullStepResult.success();
  }
}

PullFeatureRegistry buildPullRegistry(ExampleStore store) {
  return PullFeatureRegistry()
    ..register(
      PullFeature(
        name: 'documents',
        maxPagesPerRun: 1,
        steps: [
          PaginatedListPullStep(
            key: 'list',
            pageSize: 3,
            handler: DocumentListPullHandler(store),
          ),
        ],
      ),
    )
    ..register(
      PullFeature(
        name: 'workflow',
        maxPagesPerRun: 1,
        maxBatchesPerRun: 2,
        steps: [
          PaginatedListPullStep(
            key: 'list',
            pageSize: 3,
            handler: WorkflowListPullHandler(store),
          ),
          EntityBatchPullStep(
            key: 'detail',
            dependsOn: ['list'],
            batchSize: 2,
            idSelector: store.idsMissingWorkflowDetail,
            handler: WorkflowDetailPullHandler(store),
          ),
        ],
      ),
    );
}
