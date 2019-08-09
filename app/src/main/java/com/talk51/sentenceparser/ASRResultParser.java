package com.talk51.sentenceparser;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;
import java.util.ArrayList;

class ASRResultParser {
    class Word implements Serializable {
        /** 单词 */
        private String word;
        /** 单词得分 */
        private int score;

        public Word(String word, int score) {
            this.word = word;
            this.score = score;
        }
    }

    private int source;
    private String refText;
    private String recordId;
    private ArrayList<Word> words = new ArrayList<>();
    private int overall = 0;

    private void reset() {
        this.source = 0;
        this.recordId = null;
        this.refText = "";
        this.words.clear();
        this.overall = 0;
    }

    public String parse(final int source, final String result) {
        reset();

        this.source = source;
        if (source == 2) {
            parseSkegnResult(result);
        } else if (source == 3) {

        }

        return buildUnifiedResult();
    }

    private void parseSkegnResult(final String result) {
        try {
            JSONObject oldRoot = new JSONObject(result);

            if (oldRoot.has("refText")) {
                this.refText = oldRoot.getString("refText");
            }
            if (oldRoot.has("recordId")) {
                this.recordId = oldRoot.getString("recordId");
            }

            if (oldRoot.has("result")) {
                JSONObject resultObj = oldRoot.getJSONObject("result");
                if (resultObj.has("overall")) {
                    this.overall = resultObj.getInt("overall");
                } else if (resultObj.has("confidence")) {
                    this.overall = resultObj.getInt("confidence");
                }

                if (resultObj.has("words")) {
                    JSONArray wordsArr = resultObj.getJSONArray("words");
                    for (int i = 0; i < wordsArr.length(); i++) {
                        JSONObject wordObj = wordsArr.getJSONObject(i);
                        String word = wordObj.getString("word");
                        int score = 0;
                        if (wordObj.has("scores")) {
                            JSONObject scoreObj = wordObj.getJSONObject("scores");
                            score = scoreObj.getInt("overall");
                        } else if (wordObj.has("confidence")){
                            score = wordObj.getInt("confidence");
                        }

                        this.words.add(new Word(word, score));
                    }
                }
            }

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private void parseVqdResult(final String result) {
        try {
            JSONObject oldRoot = new JSONObject(result);

            if (oldRoot.has("refText")) {
                this.refText = oldRoot.getString("refText");
            }

            if (oldRoot.has("overall")) {
                this.overall = oldRoot.getInt("overall");
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    private String buildUnifiedResult() {
        try {
            JSONObject newRoot = new JSONObject();
            newRoot.put("source", this.source);
            newRoot.put("overall", this.overall);
            newRoot.put("refText", this.refText);
            if (recordId != null && recordId.length() > 0) {
                newRoot.put("recordId", this.recordId);
            }
            if (words.size() > 0) {
                JSONArray wordsArrObj = new JSONArray();
                for (Word word : words) {
                    JSONObject wordObj = new JSONObject();
                    wordObj.put("word", word.word);
                    wordObj.put("score", word.score);
                    wordsArrObj.put(wordObj);
                }
                newRoot.put("words", wordsArrObj);
            }

            return newRoot.toString();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return "";
    }
}
