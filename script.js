const revealItems = document.querySelectorAll(".reveal");
const payButtons = document.querySelectorAll(".pay-trigger");
const paymentModal = document.querySelector(".payment-modal");
const selectedPackage = document.querySelector("#selectedPackage");
const selectedAmount = document.querySelector("#selectedAmount");
const directUpiLink = document.querySelector("#directUpiLink");
const modalWhatsAppLink = document.querySelector("#modalWhatsAppLink");
const closePaymentButtons = document.querySelectorAll("[data-close-payment]");

const upiId = "7865007219@kotak811";
const payeeName = "Soumyadip Bhukta";
const screenshotWhatsApp = "917865007219";

const revealObserver = new IntersectionObserver(
  (entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add("visible");
        revealObserver.unobserve(entry.target);
      }
    });
  },
  {
    threshold: 0.14,
  }
);

revealItems.forEach((item) => revealObserver.observe(item));

function makePaymentLink(packageName, amount) {
  const params = new URLSearchParams({
    pa: upiId,
    pn: payeeName,
    am: amount,
    cu: "INR",
    tn: packageName,
  });

  return `upi://pay?${params.toString()}`;
}

function makeWhatsAppLink(packageName) {
  const text = `I paid for ${packageName}. I am sending the payment screenshot.`;
  return `https://wa.me/${screenshotWhatsApp}?text=${encodeURIComponent(text)}`;
}

function openPaymentModal(button) {
  const packageName = button.dataset.package;
  const amount = button.dataset.amount;
  const displayAmount = button.dataset.display;

  selectedPackage.textContent = packageName;
  selectedAmount.textContent = displayAmount;
  directUpiLink.href = makePaymentLink(packageName, amount);
  modalWhatsAppLink.href = makeWhatsAppLink(packageName);
  paymentModal.classList.add("active");
  paymentModal.setAttribute("aria-hidden", "false");
  document.body.classList.add("modal-open");
}

function closePaymentModal() {
  paymentModal.classList.remove("active");
  paymentModal.setAttribute("aria-hidden", "true");
  document.body.classList.remove("modal-open");
}

payButtons.forEach((button) => {
  button.addEventListener("click", () => openPaymentModal(button));
});

closePaymentButtons.forEach((button) => {
  button.addEventListener("click", closePaymentModal);
});

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape" && paymentModal.classList.contains("active")) {
    closePaymentModal();
  }
});
