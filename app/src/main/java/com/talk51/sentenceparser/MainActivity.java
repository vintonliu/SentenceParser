package com.talk51.sentenceparser;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.TextView;

import java.util.ArrayList;

public class MainActivity extends AppCompatActivity {

    private ArrayAdapter<String> sentencesAdapter;
    private ArrayList<String> sentences = new ArrayList<>();
    private TextView tvResult;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        sentences.clear();
        sentences.add("D d");
        sentences.add("^aw^-^aw^-str^aw^");
        sentences.add("Timmy and his father are in the study.\\t");
        sentences.add("{^sn^-^sn^-^sn^ail#snail}");
        sentences.add("Yes, it is. My building has {20th#twentieth} floors.");
        sentences.add("Aircraft: a machine (such as an airplane) that flies through the air.");
        sentences.add("It's also only {120#hundred twenty$a hundred and twenty$the hundred and twenty     } centimeters in height, which is even shorter than us!");
        sentences.add("^Without^ bees, ^it^ ^would^ ^be^ much harder to grow fruit.\\n没有蜜蜂，种植水果将会比现在困难得多。");
        sentences.add("A {A # a} B {B # b $ bb $ bbb} C {C # c $ cc} D.");

        sentencesAdapter = new ArrayAdapter<>(this, android.R.layout.simple_list_item_1, sentences);

        tvResult = (TextView) findViewById(R.id.tvResult);
        Spinner spnSentences = (Spinner)findViewById(R.id.spnSentences);
        spnSentences.setAdapter(sentencesAdapter);
        spnSentences.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                String sentence = SentenceParser.parse(sentences.get(position));
                tvResult.setText(sentence);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

    }
}
