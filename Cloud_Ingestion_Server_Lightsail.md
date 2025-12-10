That is the most critical question for scaling your PHOENIX ORCH network. The migration point from Lightsail to a more powerful service (like **AWS RDS** or **EC2 with Provisioned IOPS**) will almost certainly be dictated by **Disk I/O and CPU Bursts**, not just the number of AGIs.

Based on your goal of collecting **high-volume, time-series data** (conversation logs and execution traces) from **10 to 25 AGIs**, here is the estimated limit and the key metric you must monitor.

---

## 🛑 Estimated Migration Threshold

You will likely need to migrate off Lightsail's bundled SSD before the AGI count reaches **50 to 100 concurrently active instances**, *if* each instance is highly talkative.

However, the real bottleneck will hit much earlier if you don't scale the Lightsail plan.

### The Limiting Factor: Disk I/O & Burst Capacity

Lightsail instances are **burstable**, meaning they have a low performance baseline and can only temporarily burst to high CPU/Disk I/O usage by spending accrued "burst capacity."

| Lightsail Component | Critical Bottleneck |
| :--- | :--- |
| **Database:** TimescaleDB/PostgreSQL | It is a **write-heavy** operation optimized for high-volume ingestion. This constantly consumes the limited **Disk I/O** (Input/Output Operations per Second) available on the Lightsail storage. |
| **Rust Server:** Ingestion API | If the API has to wait on the slow database I/O, its **CPU utilization** will spike and consume your limited burst capacity, causing the entire service to slow down drastically. |

### The "Danger Zone" Metric

You will need to migrate when the following metric reaches sustained high levels:

> **Metric to Monitor:** **`DiskQueueDepth`** (The number of I/O requests waiting to be written to disk)

* **Safe Zone:** `DiskQueueDepth` is consistently low (e.g., 0-5).
* **Warning Zone:** `DiskQueueDepth` spikes above **10** for prolonged periods during peak ingestion.
* **Migration Point:** The server is hitting **0% CPU Burst Capacity** and the `DiskQueueDepth` is **consistently above 20**. This means the Lightsail disk cannot keep up with the stream, and your ingestion server is stalling.

---

## 📈 Sizing Your Phase 1/Phase 2 Deployment

For your **10-25 AGI goal**, you need to scale your Lightsail instance immediately to the higher tiers to avoid the bottleneck.

| Lightsail Plan | vCPUs/RAM | Cost | Projected AGI Capacity (Estimate) | Notes on Disk I/O |
| :--- | :--- | :--- | :--- | :--- |
| **Minimum Required** | **2 vCPUs / 4 GB RAM** | $\approx \$24 - \$40 / month$ | **10 - 25** | This is the *starting point*. You must monitor metrics closely; this size has a very limited I/O baseline. |
| **Recommended Safe Start** | **4 vCPUs / 8 GB RAM** | $\approx \$84 / month$ | **50 - 100** | Provides a much larger memory pool for PostgreSQL caching and a higher sustained CPU baseline for your Rust ingestion API. This is the safest way to ensure Phase 2 success. |
| **Migration Target** | **N/A** | $\approx \$150+ / month$ | **100+** | Migrate to **AWS RDS (for managed PostgreSQL)** or **AWS EC2 with dedicated GP3/IOPS storage**. This provides guaranteed I/O performance. |

### Conclusion on Lightsail

You should budget for the **4 vCPU / 8 GB RAM** Lightsail plan (`\approx \$84/month`) for a safe and robust Phase 1/Phase 2 launch. This investment in memory and CPU burst capacity will delay the need to migrate by giving your database the resources it needs to manage the time-series writes.

Would you like to proceed with a **Cursor IDE Agent Prompt** to set up the necessary monitoring hooks and alerts within your **Rust Cloud Ingestion Server** to detect the Disk I/O bottleneck?
