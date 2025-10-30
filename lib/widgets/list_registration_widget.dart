import 'package:flutter/material.dart';
import 'package:project_web/styles/app-color.dart';
import 'package:project_web/styles/text-style.dart';

class ListRegistrationWidget extends StatelessWidget {
  final TextEditingController searchController;
  final List<dynamic> filteredRegistrations;
  final bool isLoading;
  final String? error;
  final VoidCallback onSendNotification;
  final Function(int, String) onDeleteRegistration; 
  final VoidCallback onSearchChanged;
  
  final List<String> allStatuses;
  final String selectedStatus;
  final Function(String?) onStatusChanged;

  const ListRegistrationWidget({
    super.key,
    required this.searchController,
    required this.filteredRegistrations,
    required this.isLoading,
    required this.error,
    required this.onSendNotification,
    required this.onDeleteRegistration,
    required this.onSearchChanged,
    required this.allStatuses,
    required this.selectedStatus, 
    required this.onStatusChanged,
  });

  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'all':
        return 'ทั้งหมด';
      case 'in progress':
        return 'อยู่ระหว่างดำเนินการ';
      case 'payment completed':
        return 'ชำระเงินเรียบร้อย';
      case 'completed':
        return 'เสร็จสมบูรณ์';
      case 'reviewed':
        return 'แสดงความคิดเห็นแล้ว';
      default:
        return 'ไม่ระบุสถานะ';
    }
  }

  Widget _buildFilterDropdown() {
    return Container(
      width: 175,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.formBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.inputBorder, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus,
          icon: Icon(Icons.filter_list, color: AppColors.mutedBrown),
          style: TextStyles.body.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.w500),
          dropdownColor: AppColors.formBackground,
          items: allStatuses.map((String status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(_translateStatus(status)), 
            );
          }).toList(),
          onChanged: onStatusChanged,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildFilterDropdown(),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => onSearchChanged(),
                  style: TextStyles.input.copyWith(color: AppColors.primaryBlack),
                  decoration: InputDecoration(
                    labelText: 'ค้นหาด้วยชื่อนักเรียน',
                    labelStyle: TextStyles.label.copyWith(color: AppColors.secondaryText), 
                    hintText: 'กรอกชื่อ-นามสกุล นักเรียน',
                    hintStyle: TextStyles.body.copyWith(color: AppColors.secondaryText.withOpacity(0.6)),
                    prefixIcon: const Icon(Icons.search, color: AppColors.mutedBrown),
                    filled: true,
                    fillColor: AppColors.formBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.inputBorder), 
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.inputBorder), 
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.inputFocusedBorder, width: 2.0), 
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              
              ElevatedButton.icon(
                onPressed: onSendNotification,
                icon: const Icon(Icons.notifications_active, color: AppColors.buttonText, size: 20), 
                label: Text('ส่งการแจ้งเตือน', style: TextStyles.button.copyWith(fontSize: 14)), 
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkAccent,
                  foregroundColor: AppColors.buttonText,
                  shadowColor: AppColors.shadowColor.withOpacity(0.2),
                  elevation: 4, 
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          Expanded(child: _buildBody()),
        ],
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator()); 
    }
    if (error != null) {
      return Center(child: Text(error!, style: TextStyles.body.copyWith(color: AppColors.primaryBlack)));
    }
    if (filteredRegistrations.isEmpty) {
      return Center(child: Text('ไม่พบข้อมูลผู้ลงทะเบียน', style: TextStyles.body.copyWith(color: AppColors.secondaryText)));
    }
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.formBackground, 
        border: Border.all(color: AppColors.inputBorder, width: 1.0),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Material(
                  color: AppColors.formBackground,
                  child: DataTable(
                    columnSpacing: 28,
                    headingRowHeight: 50,
                    dataRowHeight: 60,
                    
                    headingRowColor: MaterialStateProperty.all(AppColors.subtleGray), 
                    headingTextStyle: TextStyles.label.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.bold),
                    
                    dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return AppColors.lightAccent;
                      }
                      return AppColors.formBackground;
                    }),
                    
                    border: TableBorder.symmetric(
                      inside: BorderSide(color: AppColors.inputBorder, width: 1),
                      outside: BorderSide.none,
                    ),

                    columns: const [
                      DataColumn(label: Text('ชื่อนักเรียน')),
                      DataColumn(label: Text('อีเมล')),
                      DataColumn(label: Text('เบอร์โทร')),
                      DataColumn(label: Text('ที่อยู่')),
                      DataColumn(label: Text('สถานะการลงทะเบียน')),
  
                    ],
                    rows: filteredRegistrations.map((data) {
                      final String rawStatus = data['registStatus'] ?? 'N/A';
                      final String translatedStatus = _translateStatus(rawStatus);
                      Color statusColor = _getStatusColor(rawStatus);
                      
                      return DataRow(
                        cells: [
                          DataCell(Text('${data['stuName'] ?? ''} ${data['stuLname'] ?? ''}', style: TextStyles.body.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.w500))),
                          DataCell(Text(data['stuEmail'] ?? 'N/A', style: TextStyles.body.copyWith(color: AppColors.primaryBlack))),
                          DataCell(Text(data['stuTel'] ?? 'N/A', style: TextStyles.body.copyWith(color: AppColors.primaryBlack))),

                          DataCell(
                            Container(
                              constraints: const BoxConstraints(maxWidth: 200), 
                              child: Text(
                                data['address'] ?? 'N/A', 
                                style: TextStyles.body.copyWith(color: AppColors.primaryBlack),
                                maxLines: 2, 
                                overflow: TextOverflow.ellipsis, 
                              ),
                            )
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(translatedStatus, style: TextStyles.body.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
        return Colors.blue.shade700;
      case 'payment completed':
        return Colors.orange.shade700;
      case 'completed':
        return Colors.green.shade700;
      case 'reviewed':
        return AppColors.mutedBrown;
      default:
        return AppColors.secondaryText;
    }
  }
}