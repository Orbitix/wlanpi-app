import '../theme/theme.dart';
import '../utils/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pi_device_model.dart';
export 'pi_device_model.dart';

class PiDeviceWidget extends StatefulWidget {
  const PiDeviceWidget({super.key});

  @override
  State<PiDeviceWidget> createState() => _PiDeviceWidgetState();
}

class _PiDeviceWidgetState extends State<PiDeviceWidget> {
  late PiDeviceModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PiDeviceModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 92.0,
      decoration: BoxDecoration(
        color: CustomTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: const AlignmentDirectional(-1.0, 0.0),
                  child: Text(
                    'wlanpi-eea',
                    style: CustomTheme.of(context).labelLarge.override(
                          fontFamily: CustomTheme.of(context).labelLargeFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts: GoogleFonts.asMap().containsKey(
                              CustomTheme.of(context).labelLargeFamily),
                        ),
                  ),
                ),
                Icon(
                  Icons.circle,
                  color: CustomTheme.of(context).secondary,
                  size: 16.0,
                ),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Model:\nR4',
                    style: CustomTheme.of(context).labelMedium.override(
                          fontFamily: CustomTheme.of(context).labelMediumFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts: GoogleFonts.asMap().containsKey(
                              CustomTheme.of(context).labelMediumFamily),
                        ),
                  ),
                  Text(
                    'Strength:\n46 dBm',
                    style: CustomTheme.of(context).labelMedium.override(
                          fontFamily: CustomTheme.of(context).labelMediumFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts: GoogleFonts.asMap().containsKey(
                              CustomTheme.of(context).labelMediumFamily),
                        ),
                  ),
                  Text(
                    'Status:\nOnline',
                    style: CustomTheme.of(context).labelMedium.override(
                          fontFamily: CustomTheme.of(context).labelMediumFamily,
                          letterSpacing: 0.0,
                          useGoogleFonts: GoogleFonts.asMap().containsKey(
                              CustomTheme.of(context).labelMediumFamily),
                        ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0.0, 0.0),
                    child: FFButtonWidget(
                      onPressed: () {
                        print('Button pressed ...');
                      },
                      text: 'Connect',
                      options: FFButtonOptions(
                        height: 40.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            24.0, 0.0, 24.0, 0.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 0.0, 0.0),
                        color: CustomTheme.of(context).alternate,
                        textStyle: CustomTheme.of(context).bodyMedium.override(
                              fontFamily:
                                  CustomTheme.of(context).bodyMediumFamily,
                              letterSpacing: 0.0,
                              useGoogleFonts: GoogleFonts.asMap().containsKey(
                                  CustomTheme.of(context).bodyMediumFamily),
                            ),
                        elevation: 3.0,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ].divide(const SizedBox(height: 2.0)),
        ),
      ),
    );
  }
}
