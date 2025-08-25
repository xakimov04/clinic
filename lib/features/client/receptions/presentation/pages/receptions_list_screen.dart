import 'package:clinic/core/ui/widgets/images/custom_cached_image.dart';
import 'package:clinic/features/client/receptions/domain/entities/reception_list_entity.dart';
import 'package:clinic/features/client/receptions/domain/entities/reception_info_entity.dart';
import 'package:clinic/features/client/receptions/presentation/bloc/reception_bloc.dart';
import 'package:clinic/features/client/receptions/presentation/widgets/file_open.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class ReceptionListScreen extends StatelessWidget {
  final String clientName;
  final String clientId;
  final String photo;

  const ReceptionListScreen({
    super.key,
    required this.clientName,
    required this.clientId,
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Медицинская карта",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.black12,
      ),
      body: BlocConsumer<ReceptionBloc, ReceptionState>(
        listener: (context, state) {
          if (state is ReceptionListLoaded) {
            _loadReceptionInfos(context, state.receptionList);
          }
        },
        builder: (context, state) {
          if (state is ReceptionListLoading) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
          } else if (state is ReceptionListLoaded) {
            return _buildReceptionList(context, state.receptionList, {}, {});
          } else if (state is ReceptionCombinedState) {
            if (state.receptionList == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildReceptionList(
              context,
              state.receptionList!,
              state.receptionInfos,
              state.loadingInfoIds,
            );
          } else if (state is ReceptionError) {
            return _buildErrorState(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildReceptionList(
    BuildContext context,
    List<ReceptionListEntity> receptionList,
    Map<String, List<ReceptionInfoEntity>> receptionInfos,
    Set<String> loadingInfoIds,
  ) {
    if (receptionList.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      itemCount: receptionList.length,
      itemBuilder: (context, index) {
        final reception = receptionList[index];
        final isLoading = loadingInfoIds.contains(reception.id);
        final receptionInfoList = receptionInfos[reception.id];

        return _ReceptionCard(
          reception: reception,
          receptionInfoList: receptionInfoList,
          photo: photo,
          isLoadingInfo: isLoading,
        );
      },
    );
  }

  void _loadReceptionInfos(
      BuildContext context, List<ReceptionListEntity> receptionList) {
    // Sequential yuklash uchun delay qo'shamiz
    for (int i = 0; i < receptionList.length; i++) {
      final reception = receptionList[i];
      Future.delayed(Duration(milliseconds: i * 200), () {
        context.read<ReceptionBloc>().add(GetReceptionsInfoEvent(reception.id));
      });
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Нет записей по приёмам",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "История приёмов появится здесь",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Произошла ошибка",
            style: TextStyle(
              fontSize: 18,
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ReceptionCard extends StatelessWidget {
  final ReceptionListEntity reception;
  final List<ReceptionInfoEntity>? receptionInfoList;
  final String photo;
  final bool isLoadingInfo;

  const _ReceptionCard({
    required this.reception,
    required this.photo,
    required this.isLoadingInfo,
    this.receptionInfoList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildAvatar(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildBasicContent(),
                    ),
                  ],
                ),
                if (isLoadingInfo) ...[
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),
                  _buildLoadingIndicator(),
                ] else if (receptionInfoList != null &&
                    receptionInfoList!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDivider(),
                  const SizedBox(height: 16),
                  _buildReceptionInfoContent(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: CacheImageWidget(
          imageUrl: photo,
          errorWidget: SvgPicture.asset(
            'assets/images/avatar.svg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildBasicContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reception.serviceName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              _formatDate(reception.visitDate),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildReceptionInfoContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: receptionInfoList!.asMap().entries.map((entry) {
        final index = entry.key;
        final info = entry.value;

        return Container(
          margin: EdgeInsets.only(
              bottom: index < receptionInfoList!.length - 1 ? 16 : 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (info.diagnosis?.isNotEmpty == true) ...[
                _buildInfoSection(
                  icon: Icons.medical_information_outlined,
                  title: "Диагноз",
                  content: info.diagnosis!,
                  color: Colors.red,
                ),
                const SizedBox(height: 12),
              ],
              if (info.treatmentPlan?.isNotEmpty == true) ...[
                _buildInfoSection(
                  icon: Icons.assignment_outlined,
                  title: "План лечения",
                  content: info.treatmentPlan!,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
              ],
              if (info.attachedFiles?.isNotEmpty == true) ...[
                _buildFileSection(context),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    required MaterialColor color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: color[600],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFileSection(BuildContext context) {
    final files = receptionInfoList!
        .expand((info) => info.attachedFiles ?? <AttachedFile>[])
        .toList();

    if (files.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.attach_file,
                size: 16,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "Прикреплённые файлы",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...files.map((file) => _buildFileItem(file, context)).toList(),
      ],
    );
  }

  Widget _buildFileItem(AttachedFile file, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!, width: 1),
      ),
      child: InkWell(
        onTap: () => FileViewerService.openFile(context, file),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                _getFileIcon(file.name),
                size: 16,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getFileSizeText(file.base64),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              size: 18,
              color: Colors.green[600],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileSizeText(String base64) {
    try {
      final cleanBase64 = base64.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');

      final padding = cleanBase64.endsWith('==')
          ? 2
          : cleanBase64.endsWith('=')
              ? 1
              : 0;
      final bytes = (cleanBase64.length * 3 / 4) - padding;

      if (bytes < 1024) {
        return '${bytes.round()} B';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return 'Unknown size';
    }
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Загружается информация о приёме...",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря'
    ];

    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
