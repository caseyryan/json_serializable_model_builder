import 'package:flutter/material.dart';
import 'package:json_serializable_model_builder/controllers/tokenizer.dart';

class TokenContainerList extends StatelessWidget {
  const TokenContainerList({
    super.key,
    required this.container,
  });

  final JsonTokenContainer container;

  @override
  Widget build(BuildContext context) {
    final tokens = container.allTokens;

    return SliverList(
      delegate: SliverChildListDelegate(
        tokens.map(
          (e) {
            return JsonTokenTile(
              token: e,
              key: ValueKey(e),
            );
          },
        ).toList(),
      ),
    );
  }
}

class JsonTokenTile extends StatelessWidget {
  const JsonTokenTile({
    super.key,
    required this.token,
  });

  final JsonToken token;

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[];
    for (var v in token.fields) {
      fields.add(
        FieldView(
          token: v,
          key: ValueKey(v),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8.0,
      ),
      child: Material(
        elevation: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    token.typeName,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  top: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: fields,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FieldView extends StatelessWidget {
  const FieldView({
    super.key,
    required this.token,
  });

  final JsonToken token;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium!;
    
    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(
            text: '${token.getFullTypeName()} ',
            style: style.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
          TextSpan(
            text: token.keyName,
          ),
          TextSpan(
            text: token.getDefaultValueView(),
          ),

        ],
      ),
    );
  }
}
