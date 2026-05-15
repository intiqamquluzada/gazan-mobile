import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '_sheet_handle.dart';

class HelpSheet extends StatelessWidget {
  const HelpSheet({super.key});

  static const List<_FAQ> _items = <_FAQ>[
    _FAQ(
      question: 'Möhürü necə qazanıram?',
      answer:
          'Sevdiyin obyektdə alış-veriş edəndə kassada QR kodunu göstər. '
          'Obyekt onu skan edən kimi möhürün avtomatik əlavə olunur.',
    ),
    _FAQ(
      question: 'Mükafatı necə alıram?',
      answer:
          'Kart tam dolanda "Kartlarım" bölməsində bildiriş görəcəksən. '
          'Növbəti ziyarətdə QR-ini göstər və mükafatını al.',
    ),
    _FAQ(
      question: 'Birdən çox kartım ola bilərmi?',
      answer:
          'Bəli! Hər obyektin öz kartı var. Bir obyektin müxtəlif '
          'proqramları üçün də ayrı kartlar yığa bilərsən.',
    ),
    _FAQ(
      question: 'Müştəri məlumatlarım kimə görünür?',
      answer:
          'Yalnız sənin kart açdığın obyektlər səni görür — və yalnız '
          'sənin onlardakı möhür və ziyarət sayını.',
    ),
    _FAQ(
      question: 'Mükafatın vaxtı bitirmi?',
      answer:
          'Bir qisim proqramların bitmə tarixi olur. Detalı kartın açılan '
          'səhifəsində görə bilərsən.',
    ),
    _FAQ(
      question: 'Telefonumu dəyişsəm kartlarım itəcəkmi?',
      answer:
          'Yox. Hesabına yenidən daxil olduqda bütün kartların və möhür '
          'tarixçən bərpa olunacaq.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SheetHandle(),
          const SizedBox(height: AppSpacing.lg),
          Text('Tez-tez verilən suallar', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.lg),
          for (final _FAQ f in _items)
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(
                  bottom: AppSpacing.md,
                ),
                title: Text(f.question, style: AppTextStyles.bodyLg),
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(f.answer, style: AppTextStyles.bodySm),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Bağla'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQ {
  const _FAQ({required this.question, required this.answer});
  final String question;
  final String answer;
}
