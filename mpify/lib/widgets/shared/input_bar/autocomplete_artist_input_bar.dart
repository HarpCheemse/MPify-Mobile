import 'package:flutter/material.dart';
import 'package:mpify/models/song_models.dart';
import 'package:mpify/widgets/shared/text_style/montserrat_style.dart';
import 'package:provider/provider.dart';

class AutocompleteArtistInputBar extends StatefulWidget {
  final TextEditingController controller;
  const AutocompleteArtistInputBar({super.key, required this.controller});

  @override
  State<AutocompleteArtistInputBar> createState() =>
      _AutocompleteArtistInputBarState();
}

class _AutocompleteArtistInputBarState
    extends State<AutocompleteArtistInputBar> {
  final FocusNode focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<SongModels>().loadArtistList();
    });
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> artistList = context.select<SongModels, List<String>>((
      models,
    ) {
      return models.artistList;
    });
    final textStyle = montserratStyle(context: context);
    final hintTextStyle = montserratStyle(
      context: context,
      color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
    );
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: focusNode,
      optionsBuilder: (TextEditingValue textEditingValue) {
        return artistList.where((String option) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return TextFormField(
              style: textStyle,
              controller: textEditingController,
              focusNode: focusNode,
              onFieldSubmitted: (String value) {
                onFieldSubmitted();
              },
              decoration: InputDecoration(
                hintText: 'Artist Name',
                hintStyle: hintTextStyle,
                fillColor: const Color.fromARGB(134, 95, 95, 95),
                prefixIcon: Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
            );
          },
      optionsViewBuilder:
          (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            final int highLighted = AutocompleteHighlightedOption.of(context);

            final itemKeys = List.generate(options.length, (_) => GlobalKey());

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (highLighted >= 0 && highLighted < itemKeys.length) {
                final key = itemKeys[highLighted];
                if (key.currentContext != null) {
                  Scrollable.ensureVisible(
                    key.currentContext!,
                    duration: const Duration(milliseconds: 100),
                    alignment: 0.5,
                  );
                }
              }
            });
            return Align(
              alignment: Alignment.topLeft,
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Material(
                  elevation: 8.0,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: options.length * 60 > 200
                          ? 200
                          : options.length * 60,
                    ),
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(8.0),
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String option = options.elementAt(index);
                        final bool isHighlighted = index == highLighted;
                        return SizedBox(
                          key: itemKeys[index],
                          width: 100,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Material(
                              color: isHighlighted
                                  ? Theme.of(context).colorScheme.surface
                                  : Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  onSelected(option);
                                },
                                hoverColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 20,
                                  ),
                                  child: Text(option, style: textStyle),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
    );
  }
}
