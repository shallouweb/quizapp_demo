import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QuizApp(),
    );
  }
}

class QuizApp extends StatefulWidget {
  @override
  _QuizAppState createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  int questionIndex = 0;
  int score = 0;
  int highScore = 0;
  final player = AudioPlayer();
  final AudioCache _audioCache = AudioCache();  // AudioCacheのインスタンスを作成
  bool isAnswerCorrect = false; // 正解かどうかを管理
  bool isAnswerSelected = false; // 回答が選ばれたかどうか

  final List<Map<String, Object>> questions = [
    // 難易度が高い問題
    {
      'questionText': 'オーバーウォッチのキャラクター「リーパー」の本名は何ですか？',
      'answers': ['ギャレット・レイノルズ', 'アナ・アモット', 'ジャック・モリソン', 'オメガ・チュー'],
      'correctAnswer': 'ギャレット・レイノルズ',
    },
    {
      'questionText': 'オーバーウォッチのゲーム内で「ドゥームフィスト」の武器は何と呼ばれていますか？',
      'answers': ['ゲンナ（The Gauntlet）', 'パワーグラブ', 'フュリオス', 'ストライカー'],
      'correctAnswer': 'ゲンナ（The Gauntlet）',
    },
    {
      'questionText': 'オーバーウォッチのシーズンイベント「ウィンターワンダーランド」の新マップはどこですか？',
      'answers': ['イースター島', 'アムステルダム', 'パリ', 'ナバル'],
      'correctAnswer': 'イースター島',
    },
    {
      'questionText': 'オーバーウォッチのキャラクター「アナ」の父親は誰ですか？',
      'answers': ['フェアリス（Farah）の母親', 'ジャック・モリソン', 'オリサ', 'リーパー'],
      'correctAnswer': 'フェアリス（Farah）の母親',
    },
    {
      'questionText': 'オーバーウォッチの「ゼニヤッタ」のオリジナルなデザインで、頭の上に何を乗せているか？',
      'answers': ['仏像', '光輪', '武器', '盾'],
      'correctAnswer': '仏像',
    },

    // 中程度の難易度の問題
    {
      'questionText': '「ソンブラ」のキャラクターの特技は何ですか？',
      'answers': ['ハッキング', 'シュート', 'ドライブ', 'フレア'],
      'correctAnswer': 'ハッキング',
    },
    {
      'questionText': 'オーバーウォッチのキャラクター「ハンゾー」の兄弟の名前は何ですか？',
      'answers': ['ゲンジ', 'リーパー', 'ブリギッテ', 'ウィンストン'],
      'correctAnswer': 'ゲンジ',
    },
    {
      'questionText': 'オーバーウォッチの「ルシオ」が使用する武器は何ですか？',
      'answers': ['サウンドウェーブと音波銃', 'ショットガンとパワーウェーブ', 'エネルギーブレード', 'ライフボール'],
      'correctAnswer': 'サウンドウェーブと音波銃',
    },
    {
      'questionText': '「メイ」の「アイスウォール」の発動には何秒かかりますか？',
      'answers': ['約10秒', '約5秒', '約8秒', '約12秒'],
      'correctAnswer': '約10秒',
    },
    {
      'questionText': 'オーバーウォッチの「ブリギッテ」の主な役割は何ですか？',
      'answers': ['サポート', 'ダメージ', 'タンク', 'アタック'],
      'correctAnswer': 'サポート',
    },

    // 簡単な問題
    {
      'questionText': '「トレーサー」の必殺技（アルティメット）は何ですか？',
      'answers': ['ブリンク', 'リワインド', 'ボム', 'クロック'],
      'correctAnswer': 'ブリンク',
    },
    {
      'questionText': 'オーバーウォッチの「レッキングボール」は何という動物ですか？',
      'answers': ['ハリネズミ', 'ゴリラ', 'ハムスター', 'タヌキ'],
      'correctAnswer': 'ハムスター',
    },
    {
      'questionText': '「リーパー」の攻撃方法は主に何ですか？',
      'answers': ['ショットガン', 'スナイパー', 'マシンガン', 'グレネード'],
      'correctAnswer': 'ショットガン',
    },
    {
      'questionText': 'オーバーウォッチのキャラクター「マーシー」の職業は何ですか？',
      'answers': ['医者（ヒーラー）', 'アサシン', 'タンク', 'エンジニア'],
      'correctAnswer': '医者（ヒーラー）',
    },
    {
      'questionText': '「アッシュ」のアルティメットで登場するロボットの名前は何ですか？',
      'answers': ['ボブ', 'ジャンクラット', 'ロボ', 'アーシー'],
      'correctAnswer': 'ボブ',
    },
  ];


  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (score > highScore) {
      await prefs.setInt('highScore', score);
      setState(() {
        highScore = score;
      });
    }
  }

  void answerQuestion(String selectedAnswer) {
    setState(() {
      isAnswerSelected = true; // 回答が選ばれた
    });

    if (selectedAnswer == questions[questionIndex]['correctAnswer']) {
      setState(() {
        isAnswerCorrect = true;
        score++; // 正解ならスコアを増やす
      });
      _audioCache.play('correct_answer.mp3'); // 正解時に音声を再生
    } else {
      setState(() {
        isAnswerCorrect = false;
      });
      _audioCache.play('wrong_answer.mp3'); // 誤答時に音声を再生
    }

    // アニメーションで色が変わった後に次の質問に進む
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        if (questionIndex + 1 < questions.length) {
          questionIndex++;
        } else {
          _saveHighScore();
          showGameOverDialog();
        }
        isAnswerSelected = false; // 回答選択をリセット
      });
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Game Over!'),
        content: Text('Your final score is: $score\nHigh Score: $highScore'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                questionIndex = 0;
                score = 0;
              });
            },
            child: Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              questions[questionIndex]['questionText'] as String,
              style: TextStyle(fontSize: 24, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ...(questions[questionIndex]['answers'] as List<String>).map((answer) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 500),
                color: isAnswerSelected
                    ? (isAnswerCorrect && answer == questions[questionIndex]['correctAnswer']
                    ? Colors.green
                    : !isAnswerCorrect && answer != questions[questionIndex]['correctAnswer']
                    ? Colors.red
                    : Colors.blue)
                    : Colors.blue, // 初期状態では青
                child: ElevatedButton(
                  onPressed: () => answerQuestion(answer),
                  child: Text(answer),
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            Text(
              'Score: $score',
              style: TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Text(
              'High Score: $highScore',
              style: TextStyle(fontSize: 20, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
