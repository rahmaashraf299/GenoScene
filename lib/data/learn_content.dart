import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GuideItem {
  final String title;
  final String description;
  final String readTime;
  final IconData icon;
  final String content;

  const GuideItem({
    required this.title,
    required this.description,
    required this.readTime,
    required this.icon,
    required this.content,
  });
}

enum LearnMediaType { image, video }

class LearnMediaItem {
  final String title;
  final String description;
  final String duration;
  final LearnMediaType type;
  final String assetPath;
  final String thumbnailPath;
  final IconData icon;
  final Color accentColor;
  final bool isFeatured;

  const LearnMediaItem({
    required this.title,
    required this.description,
    required this.duration,
    required this.type,
    required this.assetPath,
    required this.thumbnailPath,
    required this.icon,
    required this.accentColor,
    this.isFeatured = false,
  });

  bool get isVideo => type == LearnMediaType.video;
}

const learnGuides = [
  GuideItem(
    title: "GenoScene Project Idea",
    description:
        "How AI turns SNP data into trait probabilities and visual clues.",
    readTime: "4 min read",
    icon: Icons.auto_awesome_outlined,
    content:
        "GenoScene is an AI-powered DNA phenotyping application. It analyzes SNP-based genetic data to predict visible human traits such as eye color, hair color, and skin tone.\n\n"
        "The app does not treat these traits as fixed facts. It shows probability-based results, so users can see which outcome is most likely and how confident the model is.\n\n"
        "After prediction, the trait probabilities can support a visual or 3D facial representation. This helps translate genetic signals into a more understandable forensic profile.\n\n"
        "The goal is to support investigations when there is biological evidence but no direct database match. In that situation, GenoScene can provide leads about appearance while still making clear that DNA phenotyping is probabilistic, not absolute identification.",
  ),
  GuideItem(
    title: "What is DNA Phenotyping?",
    description:
        "Learn how genetic markers can predict visible appearance traits.",
    readTime: "4 min read",
    icon: Icons.biotech_outlined,
    content:
        "DNA phenotyping predicts observable traits from a person's genetic data. In forensic science, it can help estimate the appearance of an unknown person from biological evidence.\n\n"
        "GenoScene uses machine learning models trained on SNP patterns to predict eye color, hair color, and skin tone. SNPs are specific positions in the genome where people commonly differ.\n\n"
        "Important pigmentation genes include HERC2 and OCA2 for eye color, MC1R for hair pigmentation, and SLC24A5 and SLC45A2 for skin tone.\n\n"
        "The result is a set of probabilities, not a single guaranteed answer. That makes the output useful for narrowing investigative direction while keeping uncertainty visible.",
  ),
  GuideItem(
    title: "Understanding SNPs",
    description: "Single nucleotide polymorphisms and why they matter.",
    readTime: "3 min read",
    icon: Icons.scatter_plot_outlined,
    content:
        "SNPs, pronounced snips, are one of the most common forms of genetic variation. A SNP is a difference at a single DNA building block.\n\n"
        "For example, one person may have a C at a position where another person has a T. Small changes like this can be associated with differences in pigmentation and other traits.\n\n"
        "GenoScene reads selected SNP markers and converts the observed allele values into model inputs. Common encodings are 0, 1, and 2 for allele count, with NA used when a marker is missing.\n\n"
        "The model combines many SNPs at once because visible traits are usually influenced by multiple genes working together.",
  ),
  GuideItem(
    title: "How to Prepare Your CSV File",
    description: "Format SNP input data before running analysis.",
    readTime: "2 min read",
    icon: Icons.description_outlined,
    content:
        "Your CSV file should contain one column for each SNP marker expected by GenoScene.\n\n"
        "Use column names that match the required SNP and allele format, such as rs12913832_T. Each value should represent the allele count for that marker.\n\n"
        "Steps:\n"
        "1. Export raw genotype data from a lab or supported source.\n"
        "2. Map each SNP to an allele count of 0, 1, or 2.\n"
        "3. Enter NA when a SNP is unavailable.\n"
        "4. Save the file as CSV with the correct headers.\n"
        "5. Upload it through the Analysis tab.",
  ),
  GuideItem(
    title: "Eye Color Genetics",
    description: "HERC2, OCA2, and iris pigmentation prediction.",
    readTime: "5 min read",
    icon: Icons.visibility_outlined,
    content:
        "Eye color is strongly affected by the amount and distribution of melanin in the iris.\n\n"
        "Two important genes are OCA2, which is involved in melanin production, and HERC2, which helps regulate OCA2 expression.\n\n"
        "The SNP rs12913832 is one of the strongest known predictors for blue versus brown eye color, but GenoScene still evaluates multiple SNPs together.\n\n"
        "The final output is a probability distribution across possible categories, making it easier to see whether the signal is strong or uncertain.",
  ),
  GuideItem(
    title: "Hair Color Prediction",
    description: "How pigmentation pathways shape hair color.",
    readTime: "5 min read",
    icon: Icons.content_cut_outlined,
    content:
        "Hair color is influenced by the balance between eumelanin, which produces brown and black tones, and pheomelanin, which contributes red and yellow tones.\n\n"
        "MC1R is especially important for red hair. Other genes, including HERC2, SLC45A2, and IRF4, can influence darkness, lightness, and pigmentation patterns.\n\n"
        "GenoScene combines SNP evidence across these pathways to estimate probabilities for categories such as black, blond, brown, and red hair.\n\n"
        "Because hair color can be affected by age, environment, and cosmetic changes, the prediction should be read as a genetic appearance signal.",
  ),
  GuideItem(
    title: "Skin Tone Analysis",
    description: "How pigmentation genes contribute to skin tone.",
    readTime: "4 min read",
    icon: Icons.person_outline,
    content:
        "Skin tone variation is driven mainly by melanin concentration and type. Several genes contribute to this process, and many populations carry different combinations of variants.\n\n"
        "SLC24A5 and SLC45A2 are strongly associated with lighter pigmentation in some populations. HERC2, OCA2, TYR, and other genes can also contribute.\n\n"
        "GenoScene evaluates SNP signals together and returns probabilities across skin tone categories.\n\n"
        "The output is designed to communicate likely appearance while respecting that skin tone is complex and cannot be reduced to one marker.",
  ),
  GuideItem(
    title: "Reading Your Results",
    description: "Interpret confidence, probability, and uncertainty.",
    readTime: "3 min read",
    icon: Icons.bar_chart_outlined,
    content:
        "After analysis, GenoScene shows the top predicted trait and the probability assigned to each possible outcome.\n\n"
        "Higher probability means the SNP pattern more strongly supports that category. Lower or similar probabilities across categories mean the model is less certain.\n\n"
        "Use the detailed probability bars to understand uncertainty instead of only looking at the top result.\n\n"
        "DNA phenotyping supports investigation and education, but it does not identify a person by itself. It should be combined with other forensic evidence and expert review.",
  ),
];

const learnMediaItems = [
  LearnMediaItem(
    title: "What GenoScene Does",
    description:
        "A short visual overview of SNP analysis, trait probabilities, and forensic support.",
    duration: "00:36",
    type: LearnMediaType.video,
    assetPath: "assets/learn_media/genoscene_overview.mp4",
    thumbnailPath: "assets/learn_media/genoscene_overview.png",
    icon: Icons.play_circle_fill_rounded,
    accentColor: AppColors.primary,
    isFeatured: true,
  ),
  LearnMediaItem(
    title: "GenoScene Workflow",
    description:
        "Upload SNP data, run AI models, review probabilities, and generate a visual profile.",
    duration: "Image",
    type: LearnMediaType.image,
    assetPath: "assets/learn_media/genoscene_workflow.png",
    thumbnailPath: "assets/learn_media/genoscene_workflow.png",
    icon: Icons.route_outlined,
    accentColor: AppColors.success,
  ),
  LearnMediaItem(
    title: "SNPs to Visible Traits",
    description:
        "How genetic markers connect to eye color, hair color, and skin tone signals.",
    duration: "Image",
    type: LearnMediaType.image,
    assetPath: "assets/learn_media/snps_to_traits.png",
    thumbnailPath: "assets/learn_media/snps_to_traits.png",
    icon: Icons.scatter_plot_outlined,
    accentColor: AppColors.info,
  ),
  LearnMediaItem(
    title: "Forensic Support",
    description:
        "How probability-based appearance clues can help when no database match exists.",
    duration: "Image",
    type: LearnMediaType.image,
    assetPath: "assets/learn_media/forensic_support.png",
    thumbnailPath: "assets/learn_media/forensic_support.png",
    icon: Icons.person_search_outlined,
    accentColor: AppColors.warning,
  ),
];
