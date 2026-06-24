<?php

/**
 * Personal php-cs-fixer default configuration.
 *
 * Used by conform.nvim when a project doesn't ship its own
 * .php-cs-fixer.dist.php. Project configs always take precedence.
 *
 * Run manually:
 *   php-cs-fixer fix path/to/file.php \
 *     --config=~/.config/php-cs-fixer/config.php --diff
 */

use PhpCsFixer\Config\RuleCustomisationPolicyInterface;

// Walk upward from cwd looking for composer.json. @auto reads that file
// to determine target PHP version; without it, @auto throws hard.
$findComposerJson = static function (string $startDir): ?string {
    $dir = $startDir;
    while ($dir !== '' && $dir !== DIRECTORY_SEPARATOR) {
        if (is_file($dir . '/composer.json')) {
            return $dir . '/composer.json';
        }
        $parent = dirname($dir);
        if ($parent === $dir) {
            break;
        }
        $dir = $parent;
    }
    return null;
};

// Pick the base ruleset based on whether we're inside a composer project.
//   - In a composer project: @auto adapts to that project's PHP version
//     and applies the matching @PER-CS + migration rules.
//   - Outside a composer project (dotfiles, scratch files, snippets):
//     fall back to @PER-CS (latest), which doesn't need version detection.
$baseRuleset = $findComposerJson(getcwd()) !== null
    ? '@auto'
    : '@PER-CS';

// Finder uses getcwd() (not __DIR__) so it scans whichever project the
// editor is operating in, not the dotfiles dir containing this file.
$finder = (new PhpCsFixer\Finder())->in(getcwd());

/**
 * Skip statement_indentation on files that mix PHP with HTML.
 * Detected by presence of a `?>` closing tag — PSR-12 forbids closing
 * tags in pure PHP files, so any file containing one is a template.
 */
final class TemplateAwarePolicy implements RuleCustomisationPolicyInterface {
    public function getPolicyVersionForCache(): string {
        return hash_file(\PHP_VERSION_ID >= 8_01_00 ? 'xxh128' : 'md5', __FILE__);
    }

    public function getRuleCustomisers(): array {
        return [
            'statement_indentation' => static function (\SplFileInfo $file) {
                $content = @file_get_contents($file->getPathname());
                if ($content === false) {
                    return true;
                }
                return str_contains($content, '?>') ? false : true;
            },
        ];
    }
}

return (new PhpCsFixer\Config())
    ->setRules([
        $baseRuleset => true,

        // --- Opinions on things PSR-12 and @PER-CS leave unspecified ---

        // Collapse aligned `=>` to single-space separators.
        'binary_operator_spaces' => ['default' => 'single_space'],

        'braces_position' => [
            'functions_opening_brace' => 'same_line',
            'classes_opening_brace' => 'same_line',  // see note below
        ],

        // Strip padding inside array offsets: $foo[ $bar ] -> $foo[$bar]
        'no_spaces_around_offset' => ['positions' => ['inside', 'outside']],

        // Tighten unary operators: ! $foo -> !$foo, $x ++ -> $x++
        'unary_operator_spaces' => true,

        // Multi-line operators go at the START of the new line.
        // PER 6.4 requires this for booleans; only_booleans:false extends
        // it to all binary operators for cross-stack consistency with the
        // JS eslintrc's `operator-linebreak: before` rule.
        'operator_linebreak' => [
            'only_booleans' => false,
            'position' => 'beginning',
        ],

        // Trailing commas in every multi-line structure so adding,
        // removing, or reordering lines is always a single-line edit.
        // @PER-CS only does this for arrays by default.
        'trailing_comma_in_multiline' => [
            'elements' => ['arrays', 'arguments', 'parameters', 'match'],
        ],
    ])
    ->setRuleCustomisationPolicy(new TemplateAwarePolicy())
    ->setFinder($finder)
    // @auto includes risky rules — changes that may alter runtime behavior
    // (typed-property null inference, native function escaping, etc.) not
    // just whitespace. Required to opt into @auto's modernization side.
    // Harmless when falling back to @PER-CS (which has no risky rules).
    ->setRiskyAllowed(true);
