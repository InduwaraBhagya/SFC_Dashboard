import 'package:flutter/material.dart';

// ─── Data models ────────────────────────────────────────────────────────────

enum _Sender { bot, user }

class _ChatMessage {
  final _Sender sender;
  final String text;
  final List<_ChatOption>? options; // quick-reply buttons
  final DateTime time;

  _ChatMessage({
    required this.sender,
    required this.text,
    this.options,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

class _ChatOption {
  final String label;
  final String value;
  const _ChatOption(this.label, this.value);
}

// ─── Flow data ───────────────────────────────────────────────────────────────

enum _Lang { en }

// All bot messages keyed by language then step
const _botTexts = {
  _Lang.en: {
<<<<<<< HEAD
    'main_menu': 'How can I help you today? Please choose an option:',
=======
    'main_menu':
        'How can I help you today? Please choose an option:',
>>>>>>> a8ec83341e4f982d2be4d8fed993a7234253dd69
    'pe_menu': 'What would you like to do with Planned Events?',
    'records_menu': 'Which records would you like to view?',
    'bye': 'Thank you! If you need further help, feel free to ask. 😊',
    'not_understood':
        'Sorry, I didn\'t understand that. Please choose one of the options below.',
  },
};

_ChatOption _o(String label, String value) => _ChatOption(label, value);

List<_ChatOption> _mainMenuOptions(_Lang l) => [
      _o('📋 PE Management', 'pe_menu'),
      _o('📊 Reports', 'reports'),
      _o('🚨 Escalations', 'escalations'),
      _o('📁 Task Queue', 'taskqueue'),
      _o('👥 System Users', 'users'),
    ];

List<_ChatOption> _peMenuOptions(_Lang l) => [
      _o('🔍 View PE Details', 'view_pe'),
      _o('🔴 Urgent Records', 'urgent'),
      _o('🟢 Regular Records', 'regular'),
      _o('🔵 OLA Violate', 'ola'),
      _o('🟡 Hold Records', 'hold'),
      _o('⬅ Back', 'back_main'),
    ];

String _infoText(String key, _Lang l) {
  const info = {
    'reports': {
<<<<<<< HEAD
      _Lang.en:
          '📊 Go to the Reports section from the side menu to view PE reports and analytics.',
    },
    'escalations': {
      _Lang.en:
          '🚨 Go to Escalations from the side menu to track escalated issues.',
    },
    'taskqueue': {
      _Lang.en:
          '📁 Open Task Queue from PE Management in the side menu to see pending tasks.',
    },
    'users': {
      _Lang.en:
          '👥 Manage system users from the System Users option in the side menu.',
    },
    'view_pe': {
      _Lang.en:
          '🔍 Use "View PE Details" from the PE Management section to search and view PE details.',
    },
    'urgent': {
      _Lang.en:
          '🔴 Urgent Records are PEs that require immediate attention. View them from the Home dashboard.',
    },
    'regular': {
      _Lang.en:
          '🟢 Regular Records are standard PEs. View them from the Home dashboard.',
    },
    'ola': {
      _Lang.en:
          '🔵 OLA Violate Records are PEs that have violated OLA timelines. View from the Home dashboard.',
    },
    'hold': {
      _Lang.en:
          '🟡 Hold Records are PEs currently on hold. View them from the Home dashboard.',
=======
      _Lang.en: '📊 Go to the Reports section from the side menu to view PE reports and analytics.',
    },
    'escalations': {
      _Lang.en: '🚨 Go to Escalations from the side menu to track escalated issues.',
    },
    'taskqueue': {
      _Lang.en: '📁 Open Task Queue from PE Management in the side menu to see pending tasks.',
    },
    'users': {
      _Lang.en: '👥 Manage system users from the System Users option in the side menu.',
    },
    'view_pe': {
      _Lang.en: '🔍 Use "View PE Details" from the PE Management section to search and view PE details.',
    },
    'urgent': {
      _Lang.en: '🔴 Urgent Records are PEs that require immediate attention. View them from the Home dashboard.',
    },
    'regular': {
      _Lang.en: '🟢 Regular Records are standard PEs. View them from the Home dashboard.',
    },
    'ola': {
      _Lang.en: '🔵 OLA Violate Records are PEs that have violated OLA timelines. View from the Home dashboard.',
    },
    'hold': {
      _Lang.en: '🟡 Hold Records are PEs currently on hold. View them from the Home dashboard.',
>>>>>>> a8ec83341e4f982d2be4d8fed993a7234253dd69
    },
  };
  return info[key]?[l] ?? '';
}

// ─── Widget ──────────────────────────────────────────────────────────────────

class FloatingChatbot extends StatefulWidget {
  const FloatingChatbot({super.key});

  @override
  State<FloatingChatbot> createState() => _FloatingChatbotState();
}

class _FloatingChatbotState extends State<FloatingChatbot>
    with SingleTickerProviderStateMixin {
  Offset _position = const Offset(300, 500);
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
<<<<<<< HEAD
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(_pulseController);
=======
    _pulseAnim =
        Tween<double>(begin: 1.0, end: 1.08).animate(_pulseController);
>>>>>>> a8ec83341e4f982d2be4d8fed993a7234253dd69
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ChatSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => _position += d.delta),
        onTap: _openChat,
        child: ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1976D2).withValues(alpha: 0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/image.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Chat Sheet ──────────────────────────────────────────────────────────────

class _ChatSheet extends StatefulWidget {
  const _ChatSheet();

  @override
  State<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<_ChatSheet> {
  _Lang? _lang;
  final List<_ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _lang = _Lang.en;
    _messages.add(_ChatMessage(
      sender: _Sender.bot,
      text: _botTexts[_lang!]!['main_menu']!,
      options: _mainMenuOptions(_lang!),
    ));
  }

  void _onOptionTapped(_ChatOption option) {
    // Disable options on last message
    final last = _messages.last;
    if (last.options == null) return;

    // Add user message
    setState(() {
      _messages.add(_ChatMessage(sender: _Sender.user, text: option.label));
    });
    _scrollToBottom();

    // Handle the action
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _handleAction(option.value);
    });
  }

  void _handleAction(String value) {
    if (_lang == null) return;

    switch (value) {
      case 'pe_menu':
        _addBotMessage(_botTexts[_lang!]!['pe_menu']!, _peMenuOptions(_lang!));
        break;
      case 'back_main':
<<<<<<< HEAD
        _addBotMessage(
            _botTexts[_lang!]!['main_menu']!, _mainMenuOptions(_lang!));
=======
        _addBotMessage(_botTexts[_lang!]!['main_menu']!, _mainMenuOptions(_lang!));
>>>>>>> a8ec83341e4f982d2be4d8fed993a7234253dd69
        break;
      case 'reports':
      case 'escalations':
      case 'taskqueue':
      case 'users':
<<<<<<< HEAD
=======

>>>>>>> a8ec83341e4f982d2be4d8fed993a7234253dd69
      case 'view_pe':
      case 'urgent':
      case 'regular':
      case 'ola':
      case 'hold':
        final text = _infoText(value, _lang!);
<<<<<<< HEAD
        const backLabel = '⬅ Back to Menu';
=======
        final backLabel = '⬅ Back to Menu';
>>>>>>> a8ec83341e4f982d2be4d8fed993a7234253dd69
        _addBotMessage(text, [_o(backLabel, 'back_main')]);
        break;
      default:
        _addBotMessage(
            _botTexts[_lang!]!['not_understood']!, _mainMenuOptions(_lang!));
    }
  }

  void _addBotMessage(String text, List<_ChatOption> options) {
    setState(() {
      _messages.add(_ChatMessage(
        sender: _Sender.bot,
        text: text,
        options: options,
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F4F8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isLast = i == _messages.length - 1;
                return _buildMessageTile(msg, showOptions: isLast);
              },
            ),
          ),
          // Bottom date label
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Today',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF102559), Color(0xFF0A1F6D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: Image.asset(
                'assets/images/image.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const CircleAvatar(
                  backgroundColor: Colors.white24,
<<<<<<< HEAD
                  child: Icon(Icons.smart_toy_rounded, color: Colors.white),
=======
                  child:
                      Icon(Icons.smart_toy_rounded, color: Colors.white),
>>>>>>> a8ec83341e4f982d2be4d8fed993a7234253dd69
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SFC Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.greenAccent,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Online',
<<<<<<< HEAD
                      style: TextStyle(color: Colors.greenAccent, fontSize: 11),
=======
                      style:
                          TextStyle(color: Colors.greenAccent, fontSize: 11),
>>>>>>> a8ec83341e4f982d2be4d8fed993a7234253dd69
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(_ChatMessage msg, {required bool showOptions}) {
    final isBot = msg.sender == _Sender.bot;

    return Column(
      crossAxisAlignment:
          isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        if (isBot)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Bot avatar
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 6, bottom: 2),
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/image.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const CircleAvatar(
                      backgroundColor: Color(0xFF102559),
                      child: Icon(Icons.smart_toy_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
<<<<<<< HEAD
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
=======
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
>>>>>>> a8ec83341e4f982d2be4d8fed993a7234253dd69
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: const TextStyle(fontSize: 13.5, height: 1.45),
                  ),
                ),
              ),
            ],
          )
        else
          Container(
            margin: const EdgeInsets.only(bottom: 4, left: 48),
<<<<<<< HEAD
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
=======
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
>>>>>>> a8ec83341e4f982d2be4d8fed993a7234253dd69
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              msg.text,
              style: const TextStyle(
                  fontSize: 13.5, color: Colors.white, height: 1.4),
            ),
          ),
        // Options (only on last bot message)
        if (isBot && msg.options != null && showOptions)
          Padding(
            padding: const EdgeInsets.only(left: 38, top: 6, bottom: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: msg.options!
                  .map((opt) => _OptionChip(
                        label: opt.label,
                        onTap: () => _onOptionTapped(opt),
                      ))
                  .toList(),
            ),
          )
        else
          const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Option chip ─────────────────────────────────────────────────────────────

class _OptionChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _OptionChip({required this.label, required this.onTap});

  @override
  State<_OptionChip> createState() => _OptionChipState();
}

class _OptionChipState extends State<_OptionChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
<<<<<<< HEAD
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
=======
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
>>>>>>> a8ec83341e4f982d2be4d8fed993a7234253dd69
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFF1565C0) : Colors.white,
          border: Border.all(color: const Color(0xFF1565C0), width: 1.4),
          borderRadius: BorderRadius.circular(20),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            color: _pressed ? Colors.white : const Color(0xFF1565C0),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
