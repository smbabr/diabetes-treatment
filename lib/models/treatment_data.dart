/// All treatment matching logic, symptom lists, and treatment URLs.
/// This is a direct port of the JavaScript logic from the web version.

class TreatmentData {
  // ─────────────────── WHATSAPP ───────────────────
  static const String whatsappNumber = '923342134532';

  // ─────────────────── TREATMENT URLS ─────────────
  static const Map<String, String> treatments = {
    'T1_DA1': 'https://sites.google.com/view/diabetestitreatment/home',
    'T1_DA2': 'https://sites.google.com/view/diabetestitreatment/home',
    'T1_DA3': 'https://sites.google.com/view/diabetestitreatment/home',
    'T1_DA4': 'https://sites.google.com/view/diabetestitreatment/home',
    'T2_DU1': 'https://sites.google.com/view/diabetestt2treatment/home',
    'T2_DU2': 'https://sites.google.com/view/diabetestt2treatment/home',
    'T2_DU3': 'https://sites.google.com/view/diabetestt2treatment/home',
    'T2_DU4': 'https://sites.google.com/view/diabetestt2treatment/home',
    'T2_DU5': 'https://sites.google.com/view/diabetestt2treatment/home',
    'T2_DU6': 'https://sites.google.com/view/diabetestt2treatment/home',
    'T2_DU7': 'https://sites.google.com/view/diabetestt2treatment/home',
    'T2_DU8': 'https://sites.google.com/view/diabetestt2treatment/home',
    'T2_DU': 'https://sites.google.com/view/diabetestt2treatment/home',
    'T2_DG1': 'https://sites.google.com/view/diabetestype2-g1/home',
    'T2_DG2': 'https://sites.google.com/view/diabetestype2-g1/home',
    'T2_DG3': 'https://sites.google.com/view/diabetestype2-g1/home',
    'T2_DG4': 'https://sites.google.com/view/diabetestype2-g1/home',
    'T2_DG5': 'https://sites.google.com/view/diabetestype2-g1/home',
    'T2_DG6': 'https://sites.google.com/view/diabetestype2-g1/home',
    'T2_DG7': 'https://sites.google.com/view/diabetestype2-g1/home',
    'T2_DG8': 'https://sites.google.com/view/diabetestype2-g1/home',
    'T2_DG9': 'https://sites.google.com/view/diabetestype2-g1/home',
    'T2_DG10': 'https://sites.google.com/view/diabetestype2-g1/home',
    'T2_DG11': 'https://sites.google.com/view/diabetestype2-g1/home',
    'T2_DG12': 'https://sites.google.com/view/diabetestype2-g1/home',
    'T2_DG13': 'https://sites.google.com/view/diabetestype2-g1/home',
    'T2_DG14': 'https://sites.google.com/view/diabetestype2-g1/home',
    'T2_DG15': 'https://sites.google.com/view/diabetestype2-g1/home',
    'T2_DG17': 'https://sites.google.com/view/diabetestype2-g1/home',
    'T2_DG': 'https://sites.google.com/view/diabetestype2-g1/home',
  };

  // ─────────────────── VIDEO URLS ─────────────────
  static const String t1VideoUrl =
      'https://www.youtube.com/watch?v=jxbbBmbvu7I';
  static const String t2VideoUrl =
      'https://www.youtube.com/watch?v=OXAe3eOjqCk';

  // ─────────────────── SYMPTOM LISTS ──────────────

  /// Type 1 symptoms (Low C-Peptide + High Glucose)
  static const List<String> t1Symptoms = [
    'Diabetes',
    'Constipation',
    'Frequent Urination',
    'Ketone Bodies',
    'Male Sexual Weakness',
    'Development of Boils and Pimples on the scalp',
  ];

  /// DU symptoms (High Uric Acid + High Cholesterol)
  static const List<String> duSymptoms = [
    'Diabetes',
    'Constipation',
    'Obesity',
    'Loss of Appetite',
    'Burning Sensation in Hands and Feet',
    'Heartburn',
    'Foot Pain and Swelling',
    'Anxiety',
    'Pain in Calves',
    'Fever',
    'Chest Pain',
    'Feet Going Numb',
    'Body Pain',
    'Blood in Urine',
    'Breast Pain',
    'Knee Pain',
    'Allergy',
    'High Blood Pressure',
    'Cholesterol',
    'Triglyceride',
  ];

  /// DG symptoms (Bilirubin High)
  static const List<String> dgSymptoms = [
    'Diabetes',
    'Constipation',
    'Blisters and Sores in the Mouth',
    'Lack of Sleep',
    'Acute Hepatitis A',
    'Acute Hepatitis C',
    'Fatty Liver',
    'Body Pain',
    'Back Pain',
    'Muscle Pain',
    'Joint Pain',
    'Cough',
    'Fever',
    'Painful Urination',
    'Chronic Hepatitis A',
    'Chronic Hepatitis C',
    'Nail Like Pimples on the Hands',
    'Frequent Urination',
    'High Blood Pressure',
    'Hemorrhoids(Anal Piles)',
    'Burning Sensation in Hands and Feet',
    'Allergy and Itching',
    'Kidney Stones',
    'Shortness of Breath',
    'Shrunken Kidney',
    'Cirrhosis',
  ];

  /// Emergency symptoms that trigger a warning
  static const List<String> emergencySymptoms = [
    'Ketone Bodies',
    'Chest Pain',
    'Shortness of Breath',
    'Feet Going Numb',
  ];

  // ─────────────────── MATCHING LOGIC ─────────────

  static bool _hasAll(List<String> selected, List<String> required) {
    return required.every((s) => selected.contains(s));
  }

  /// Get treatment code for Type 1 symptoms
  static String getT1Treatment(List<String> symptoms) {
    if (_hasAll(symptoms, [
      'Diabetes',
      'Constipation',
      'Development of Boils and Pimples on the scalp',
    ])) return 'T1_DA4';

    if (_hasAll(symptoms, [
      'Diabetes',
      'Constipation',
      'Male Sexual Weakness',
    ])) return 'T1_DA3';

    if (_hasAll(symptoms, [
      'Diabetes',
      'Constipation',
      'Ketone Bodies',
    ])) return 'T1_DA2';

    if (_hasAll(symptoms, [
      'Diabetes',
      'Constipation',
      'Frequent Urination',
    ])) return 'T1_DA1';

    if (_hasAll(symptoms, ['Diabetes', 'Constipation'])) return 'T1_DA1';
    if (_hasAll(symptoms, ['Diabetes'])) return 'T1_DA1';

    return 'T1_DA1';
  }

  /// Get treatment code for DU (Uric/Cholesterol) symptoms
  static String getDUTreatment(List<String> s) {
    if (_hasAll(s, ['Diabetes', 'Constipation', 'Cholesterol', 'Triglyceride']))
      return 'T2_DU8';
    if (_hasAll(s, ['Diabetes', 'Cholesterol', 'Triglyceride']))
      return 'T2_DU8';
    if (_hasAll(s, ['Diabetes', 'Constipation', 'Cholesterol']))
      return 'T2_DU8';
    if (_hasAll(s, ['Diabetes', 'Cholesterol'])) return 'T2_DU8';

    if (_hasAll(s, ['Diabetes', 'Breast Pain', 'Knee Pain', 'Allergy']))
      return 'T2_DU7';
    if (_hasAll(s, ['Diabetes', 'Breast Pain', 'Knee Pain'])) return 'T2_DU7';
    if (_hasAll(s, ['Diabetes', 'Breast Pain'])) return 'T2_DU7';

    if (_hasAll(s, ['Diabetes', 'Constipation', 'Blood in Urine']))
      return 'T2_DU6';
    if (_hasAll(s, ['Diabetes', 'Blood in Urine'])) return 'T2_DU6';

    if (_hasAll(s, ['Diabetes', 'Constipation', 'Body Pain'])) return 'T2_DU5';

    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Fever',
      'Chest Pain',
      'Feet Going Numb',
    ])) return 'T2_DU4';
    if (_hasAll(s, ['Diabetes', 'Constipation', 'Fever', 'Chest Pain']))
      return 'T2_DU4';
    if (_hasAll(s, ['Diabetes', 'Constipation', 'Fever'])) return 'T2_DU4';

    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Heartburn',
      'Foot Pain and Swelling',
      'Anxiety',
      'Pain in Calves',
    ])) return 'T2_DU3';
    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Heartburn',
      'Foot Pain and Swelling',
      'Anxiety',
    ])) return 'T2_DU3';
    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Heartburn',
      'Foot Pain and Swelling',
    ])) return 'T2_DU3';
    if (_hasAll(s, ['Diabetes', 'Constipation', 'Heartburn'])) return 'T2_DU3';

    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Obesity',
      'Loss of Appetite',
      'High Blood Pressure',
      'Burning Sensation in Hands and Feet',
    ])) return 'T2_DU2';
    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Obesity',
      'Loss of Appetite',
      'High Blood Pressure',
    ])) return 'T2_DU2';
    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Obesity',
      'Loss of Appetite',
    ])) return 'T2_DU2';
    if (_hasAll(s, ['Diabetes', 'Constipation', 'Obesity'])) return 'T2_DU2';
    if (_hasAll(s, ['Diabetes', 'Constipation'])) return 'T2_DU2';
    if (_hasAll(s, ['Diabetes'])) return 'T2_DU1';

    return 'T2_DU';
  }

  /// Get treatment code for DG (Bilirubin) symptoms
  static String getDGTreatment(List<String> s) {
    if (_hasAll(s, ['Diabetes', 'Constipation', 'Cirrhosis']))
      return 'T2_DG17';

    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Shortness of Breath',
      'Shrunken Kidney',
    ])) return 'T2_DG15';

    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'High Blood Pressure',
      'Kidney Stones',
    ])) return 'T2_DG14';

    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Burning Sensation in Hands and Feet',
      'Allergy and Itching',
    ])) return 'T2_DG13';
    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Burning Sensation in Hands and Feet',
    ])) return 'T2_DG13';

    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Frequent Urination',
      'High Blood Pressure',
      'Fever',
      'Hemorrhoids(Anal Piles)',
    ])) return 'T2_DG12';
    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Frequent Urination',
      'High Blood Pressure',
      'Hemorrhoids(Anal Piles)',
    ])) return 'T2_DG12';
    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Frequent Urination',
      'Hemorrhoids(Anal Piles)',
    ])) return 'T2_DG12';
    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Hemorrhoids(Anal Piles)',
    ])) return 'T2_DG12';

    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Chronic Hepatitis C',
      'Nail Like Pimples on the Hands',
    ])) return 'T2_DG11';
    if (_hasAll(s, [
      'Diabetes',
      'Chronic Hepatitis C',
      'Nail Like Pimples on the Hands',
    ])) return 'T2_DG11';
    if (_hasAll(s, ['Diabetes', 'Constipation', 'Chronic Hepatitis C']))
      return 'T2_DG11';

    if (_hasAll(s, ['Diabetes', 'Constipation', 'Chronic Hepatitis A']))
      return 'T2_DG10';

    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Painful Urination',
      'Acute Hepatitis C',
    ])) return 'T2_DG9';

    if (_hasAll(s, ['Diabetes', 'Constipation', 'Acute Hepatitis C', 'Fever']))
      return 'T2_DG8';
    if (_hasAll(s, ['Diabetes', 'Acute Hepatitis C', 'Fever']))
      return 'T2_DG8';

    if (_hasAll(s, ['Diabetes', 'Constipation', 'Cough'])) return 'T2_DG7';

    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Muscle Pain',
      'Joint Pain',
    ])) return 'T2_DG6';
    if (_hasAll(s, ['Diabetes', 'Constipation', 'Muscle Pain']))
      return 'T2_DG6';

    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Fatty Liver',
      'Body Pain',
      'Back Pain',
      'Muscle Pain',
    ])) return 'T2_DG5';
    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Fatty Liver',
      'Body Pain',
      'Back Pain',
    ])) return 'T2_DG5';
    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Fatty Liver',
      'Body Pain',
    ])) return 'T2_DG5';

    if (_hasAll(s, ['Diabetes', 'Constipation', 'Fatty Liver']))
      return 'T2_DG4';
    if (_hasAll(s, ['Diabetes', 'Constipation', 'Acute Hepatitis C']))
      return 'T2_DG4';
    if (_hasAll(s, ['Diabetes', 'Constipation', 'Acute Hepatitis A']))
      return 'T2_DG4';

    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Blisters and Sores in the Mouth',
      'Lack of Sleep',
    ])) return 'T2_DG3';
    if (_hasAll(s, [
      'Diabetes',
      'Constipation',
      'Blisters and Sores in the Mouth',
    ])) return 'T2_DG3';

    if (_hasAll(s, ['Diabetes', 'Constipation'])) return 'T2_DG2';
    if (_hasAll(s, ['Diabetes'])) return 'T2_DG1';

    return 'T2_DG';
  }

  /// Check if any emergency symptoms are selected
  static bool hasEmergencySymptoms(List<String> symptoms) {
    return symptoms.any((s) => emergencySymptoms.contains(s));
  }
}
