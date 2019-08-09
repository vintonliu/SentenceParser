package com.talk51.sentenceparser;

import android.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

class SentenceParser {
    private final static String TAG = "SentenceParser";
    public SentenceParser() {

    }

    public static String parse(String sentence) {
        if (sentence.contains("+")) {
            // wrong format, don't parse
            return sentence;
        }

//        log(sentence);

        // replace "\t, \r, \n, ^, chinese( [^\x20-\x7e]* )" to null
        Pattern pattern = Pattern.compile("\\\\t|\\\\r|\\\\n|\\^|[^\\x20-\\x7e]*");
        Matcher matcher = pattern.matcher(sentence);
        sentence = matcher.replaceAll("");

//        log(sentence);

        // replace "-, (, )" to space
        pattern = Pattern.compile("[-()]");
        matcher = pattern.matcher(sentence);
        sentence = matcher.replaceAll(" ");

//        log(sentence);

        /* process pattern "A a" return "A" */
        String[] words = sentence.split(" ");
        if (words.length == 2 && words[0].equalsIgnoreCase(words[1])) {
            return words[0].toUpperCase();
        }

        /* process pattern {a # b $ c} */
        int choiceSize = checkChoiceSentence(sentence);
        if (choiceSize > 0) {
//            log("choiceSize = " + choiceSize);
            sentence = parseChoiceSentence(sentence);
        }

        // replace multi spaces to one space
        pattern = Pattern.compile("[ ]+");
        matcher = pattern.matcher(sentence);
        sentence = matcher.replaceAll(" ");

        return sentence;
    }

    /** Example: A {A # a} B {B # b $ bb $ bbb} C {C # c $ cc} D. */
    private static String parseChoiceSentence(String sentence) {
        StringBuilder builder = new StringBuilder();
        ArrayList<StringBuilder> sentences = new ArrayList<>();
        ArrayList<String> originList = new ArrayList<>();
        ArrayList<String> choiceList = new ArrayList<>();
        HashMap<String, ArrayList<String>> choiceSentences = new HashMap<>();

        String tempStr = sentence;
        int openIndex, closeIndex;
        while ((openIndex = tempStr.indexOf("{")) != -1) {
            originList.add(tempStr.substring(0, openIndex));

            closeIndex = tempStr.indexOf("}");
            String choice = tempStr.substring(openIndex + 1, closeIndex);
            if (choice.contains("#")) {
                String[] words = choice.split("#");
                if ((words.length == 2) &&
                    (words[0].length() > 0) &&
                    (words[1].length() > 0)) {
                    String key = words[0];
                    choiceList.add(key);
                    ArrayList<String> choices = new ArrayList<>(Arrays.asList(words[1].split("\\$")));
                    choiceSentences.put(key, choices);
                }
            }

            tempStr = tempStr.substring(closeIndex + 1);
        }
        // last partial if have
        if (tempStr.length() > 0) {
            originList.add(tempStr);
        }

        /* Combine all possibilities sentence */
        for (int i = 0; i < originList.size(); ++i) {
            if (i == 0) {
                StringBuilder sent = new StringBuilder();
                sent.append(originList.get(i));
                sentences.add(sent); // one element
            } else {
                for (StringBuilder sent : sentences) {
                    sent.append(originList.get(i));
                }
            }

            if (i < choiceList.size()) {
                String choice = choiceList.get(i);
                ArrayList<String> choices = choiceSentences.get(choice);
                int size = choices.size();
                ArrayList<StringBuilder> tmpSents = new ArrayList<>(sentences);
                sentences.clear();
                for (int j = 0; j < size; ++j) {
                    for (StringBuilder sent : tmpSents) {
                        StringBuilder tmpSB = new StringBuilder(sent);
                        tmpSB.append(choices.get(j));
                        sentences.add(tmpSB);
                    }
                }
            }
        }

        /* Combine all sentences in one */
        for (int idx = 0; idx < sentences.size(); ++idx) {
            if (idx != 0) {
                builder.append("|");
            }
            builder.append(sentences.get(idx));
//            log(sentences.get(idx).toString());
        }

        return builder.toString();
    }

    private static int checkChoiceSentence(String sentence) {
        int openCount = 0;
        int closeCount = 0;
        String tempStr = sentence;
        int openIndex, closeIndex;

        while ((openIndex = tempStr.indexOf("{")) != -1) {
            ++openCount;

            if ((closeIndex = tempStr.indexOf("}")) > openIndex) {
                ++closeCount;
            } else {
                break;
            }
            tempStr = tempStr.substring(closeIndex + 1);
        }

        if (openCount != closeCount) {
            return -1;
        }

        return openCount;
    }

    private static void log(String msg) {
        Log.i(TAG, msg);
    }
}
