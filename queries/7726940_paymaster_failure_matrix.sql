-- ERC-4337 Paymaster Failure / Reliability Matrix
-- Chain: Base
-- Window: 30 days

WITH aa_raw AS (
    SELECT
        block_time,
        blockchain,
        paymaster,
        bundler,
        sender,
        success,
        COALESCE(op_fee_usd, 0) AS op_fee_usd,
        op_fee
    FROM account_abstraction_erc4337.userops
    WHERE block_time >= NOW() - INTERVAL '30' DAY
      AND blockchain = 'base'
      AND paymaster IS NOT NULL
      AND paymaster != 0x0000000000000000000000000000000000000000
),

paymaster_stats AS (
    SELECT
        paymaster,
        COUNT(*) AS total_ops,
        COUNT_IF(success = false) AS failed_ops,
        COUNT_IF(success = true) AS successful_ops,
        ROUND(SUM(op_fee_usd), 2) AS total_fee_usd,
        ROUND(SUM(CASE WHEN success = false THEN op_fee_usd ELSE 0 END), 2) AS failed_fee_usd,
        ROUND(100.0 * COUNT_IF(success = false) / COUNT(*), 2) AS fail_rate_pct,
        COUNT(DISTINCT sender) AS unique_senders,
        COUNT(DISTINCT bundler) AS unique_bundlers
    FROM aa_raw
    GROUP BY paymaster
),

top_failed_sender AS (
    SELECT
        paymaster,
        sender AS top_failed_sender,
        COUNT(*) AS top_sender_failed_ops,
        ROUND(SUM(op_fee_usd), 2) AS top_sender_failed_fee_usd,
        ROW_NUMBER() OVER (
            PARTITION BY paymaster
            ORDER BY COUNT(*) DESC, SUM(op_fee_usd) DESC
        ) AS rn
    FROM aa_raw
    WHERE success = false
    GROUP BY paymaster, sender
),

top_bundler AS (
    SELECT
        paymaster,
        bundler AS top_bundler,
        COUNT(*) AS bundler_ops,
        ROUND(SUM(op_fee_usd), 2) AS bundler_fee_usd,
        ROW_NUMBER() OVER (
            PARTITION BY paymaster
            ORDER BY COUNT(*) DESC, SUM(op_fee_usd) DESC
        ) AS rn
    FROM aa_raw
    GROUP BY paymaster, bundler
)

SELECT
    ps.paymaster AS "Paymaster",
    ps.total_ops AS "Total Ops",
    ps.successful_ops AS "Successful Ops",
    ps.failed_ops AS "Failed Ops",
    ps.fail_rate_pct AS "Fail Rate %",
    ps.total_fee_usd AS "Total Fee USD",
    ps.failed_fee_usd AS "Failed Fee USD",
    ps.unique_senders AS "Unique Senders",
    ps.unique_bundlers AS "Unique Bundlers",
    tfs.top_failed_sender AS "Top Failed Sender",
    tfs.top_sender_failed_ops AS "Top Sender Failed Ops",
    tfs.top_sender_failed_fee_usd AS "Top Sender Failed Fee USD",
    tb.top_bundler AS "Top Bundler",
    tb.bundler_ops AS "Top Bundler Ops",
    tb.bundler_fee_usd AS "Top Bundler Fee USD"
FROM paymaster_stats ps
LEFT JOIN top_failed_sender tfs
    ON ps.paymaster = tfs.paymaster
   AND tfs.rn = 1
LEFT JOIN top_bundler tb
    ON ps.paymaster = tb.paymaster
   AND tb.rn = 1
WHERE ps.failed_ops > 0
ORDER BY
    ps.failed_fee_usd DESC,
    ps.fail_rate_pct DESC,
    ps.total_fee_usd DESC
LIMIT 50;
