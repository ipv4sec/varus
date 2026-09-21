import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:varus/widgets/customized_appbar.dart';


class AboutPage extends StatelessWidget {
   AboutPage({Key? key}) : super(key: key);

  Widget _agreementLink(BuildContext context, String title) {
    return InkWell(
      onTap: () => _showAgreementDialog(context, title),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  void _showAgreementDialog(BuildContext context, String title) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: const Text('TODO: 协议内容'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomizedAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Html(data: '''
<article>
    
    <h3>The MIT License (MIT)</h3>

    <p>Copyright © 2023 齐凤龙</p>

    <p>Permission is hereby granted, free of charge, to any person obtaining a copy
      of this software and associated documentation files (the “Software”), to deal
      in the Software without restriction, including without limitation the rights
      to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      copies of the Software, and to permit persons to whom the Software is
      furnished to do so, subject to the following conditions:</p>

    <p>The above copyright notice and this permission notice shall be included in
      all copies or substantial portions of the Software.</p>

    <p>THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
      THE SOFTWARE.</p>
</article> '''),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _agreementLink(context, '隐私协议'),
                  const SizedBox(width: 32),
                  _agreementLink(context, '用户协议'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
