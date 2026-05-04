const upiId = "7865007219@kotak811";
const payeeName = "Soumyadip Bhukta";
const screenshotWhatsApp = "917865007219";
const latestOrderKey = "soumyadipGraphicsLatestOrder";
const allOrdersKey = "soumyadipGraphicsOrders";
const reviewsKey = "soumyadipGraphicsReviews";
const reviewPopupKey = "soumyadipGraphicsReviewPopupSeen";

const state = {
  selectedService: "",
  selectedAmount: "0",
  selectedDisplay: "Rs 0",
};

function initPageLoader() {
  if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    return;
  }

  document.body.classList.add("is-loading");
  const loader = document.createElement("div");
  loader.className = "page-loader";
  loader.setAttribute("aria-hidden", "true");
  loader.innerHTML = '<span class="loader-mark"></span>';
  document.body.prepend(loader);

  const hideLoader = () => {
    loader.classList.add("hidden");
    document.body.classList.remove("is-loading");
    window.setTimeout(() => loader.remove(), 800);
  };

  if (document.readyState === "complete") {
    window.setTimeout(hideLoader, 450);
  } else {
    window.addEventListener("load", () => window.setTimeout(hideLoader, 450), { once: true });
  }
}

function qs(selector, parent = document) {
  return parent.querySelector(selector);
}

function qsa(selector, parent = document) {
  return [...parent.querySelectorAll(selector)];
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (character) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
  }[character]));
}

function formatAmount(amount) {
  const numericAmount = Number(amount);
  if (numericAmount <= 0) {
    return "Quote Required";
  }

  return `Rs ${numericAmount.toLocaleString("en-IN")}`;
}

function normalizeAmount(amount) {
  const numericAmount = Number(amount);
  return Number.isFinite(numericAmount) && numericAmount > 0 ? String(numericAmount) : "1";
}

function makeOrderId() {
  const stamp = Date.now().toString(36).toUpperCase();
  const random = Math.random().toString(36).slice(2, 6).toUpperCase();
  return `SG-${stamp}-${random}`;
}

function readLatestOrder() {
  try {
    return JSON.parse(localStorage.getItem(latestOrderKey) || "null");
  } catch (error) {
    return null;
  }
}

function readOrders() {
  try {
    return JSON.parse(localStorage.getItem(allOrdersKey) || "[]");
  } catch (error) {
    return [];
  }
}

function saveOrder(order) {
  let orders = [];
  try {
    orders = JSON.parse(localStorage.getItem(allOrdersKey) || "[]");
  } catch (error) {
    orders = [];
  }

  orders.unshift(order);
  localStorage.setItem(allOrdersKey, JSON.stringify(orders.slice(0, 40)));
  localStorage.setItem(latestOrderKey, JSON.stringify(order));
}

function makePaymentLink(label, amount, orderId = "") {
  const upi = "7865007219@kotak811";
  const name = encodeURIComponent("Soumyadip Bhukta");
  const safeAmount = normalizeAmount(amount);
  const note = encodeURIComponent(orderId ? `${orderId} - ${label}` : label);

  return `upi://pay?pa=${upi}&pn=${name}&am=${safeAmount}&cu=INR&tn=${note}`;
}

function makeWhatsAppLink(order) {
  const text = [
    "New design order",
    `Order ID: ${order.orderId || "Not generated"}`,
    `Name: ${order.name || "Client"}`,
    `Phone: ${order.phone || "Not provided"}`,
    `Service: ${order.service}`,
    `Amount: ${formatAmount(order.amount)}`,
    `Details: ${order.details || "Payment screenshot attached."}`,
  ].join("\n");

  return `https://wa.me/${screenshotWhatsApp}?text=${encodeURIComponent(text)}`;
}

function makePreOrderWhatsAppLink(service, amount) {
  const text = [
    "Hello, I want to order a design.",
    `Service: ${service}`,
    `Amount: ${formatAmount(amount)}`,
    "Please confirm availability and next steps.",
  ].join("\n");

  return `https://wa.me/${screenshotWhatsApp}?text=${encodeURIComponent(text)}`;
}

function makePaymentConfirmationLink(order) {
  const text = [
    "Payment completed",
    `Order ID: ${order.orderId || "Not generated"}`,
    `Service: ${order.service}`,
    `Amount: ${formatAmount(order.amount)}`,
    "I am sending the payment screenshot now.",
  ].join("\n");

  return `https://wa.me/${screenshotWhatsApp}?text=${encodeURIComponent(text)}`;
}

function initRevealAnimations() {
  const revealItems = qsa(".reveal");
  if (!revealItems.length) {
    return;
  }

  const styles = ["reveal-rise", "reveal-zoom", "reveal-slide", "reveal-soft"];
  revealItems.forEach((item, index) => {
    item.classList.add(styles[index % styles.length]);
    item.style.setProperty("--reveal-delay", `${Math.min(index % 6, 5) * 70}ms`);
  });

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
      threshold: 0.18,
      rootMargin: "0px 0px -8% 0px",
    }
  );

  revealItems.forEach((item) => revealObserver.observe(item));
}

function createParticles(target, count, className = "magic-particle") {
  if (!target) {
    return;
  }

  if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
    return;
  }

  const isSmallScreen = window.matchMedia("(max-width: 680px)").matches;
  const total = isSmallScreen ? Math.ceil(count * 0.24) : count;

  for (let index = 0; index < total; index += 1) {
    const particle = document.createElement("span");
    particle.className = className;
    particle.style.left = `${Math.random() * 100}%`;
    particle.style.animationDelay = `${Math.random() * 8}s`;
    particle.style.animationDuration = `${7 + Math.random() * 8}s`;
    particle.style.opacity = `${0.25 + Math.random() * 0.65}`;
    target.appendChild(particle);
  }
}

function initParticles() {
  createParticles(qs("[data-particles]"), 58);
  createParticles(qs("[data-particles-deep]"), 36, "magic-particle deep-particle");
  createParticles(qs("[data-payment-particles]"), 38, "magic-particle payment-particle");
  createParticles(qs("[data-main-nature-particles]"), 48, "main-nature-particle");
}

function initLightbox() {
  const imageLightbox = qs(".image-lightbox");
  const lightboxImage = imageLightbox ? qs("img", imageLightbox) : null;
  const closeLightboxButton = qs("[data-close-lightbox]");

  qsa(".portfolio-item img").forEach((image) => {
    image.loading = "lazy";
    image.decoding = "async";
  });

  function closeLightbox() {
    if (!imageLightbox || !lightboxImage) {
      return;
    }

    imageLightbox.classList.remove("active");
    imageLightbox.setAttribute("aria-hidden", "true");
    lightboxImage.src = "";
    document.body.classList.remove("modal-open");
  }

  qsa(".portfolio-item").forEach((item) => {
    item.addEventListener("click", () => {
      if (!imageLightbox || !lightboxImage) {
        return;
      }

      lightboxImage.src = item.dataset.full;
      imageLightbox.classList.add("active");
      imageLightbox.setAttribute("aria-hidden", "false");
      document.body.classList.add("modal-open");
    });
  });

  if (imageLightbox) {
    imageLightbox.addEventListener("click", (event) => {
      if (event.target === imageLightbox) {
        closeLightbox();
      }
    });
  }

  if (closeLightboxButton) {
    closeLightboxButton.addEventListener("click", closeLightbox);
  }

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && imageLightbox && imageLightbox.classList.contains("active")) {
      closeLightbox();
    }
  });
}

function updatePaymentModal(order) {
  const selectedPackage = qs("#selectedPackage");
  const selectedAmount = qs("#selectedAmount");
  const selectedOrderId = qs("#selectedOrderId");
  const selectedClientName = qs("#selectedClientName");
  const directUpiLink = qs("#directUpiLink");
  const modalWhatsAppLink = qs("#modalWhatsAppLink");

  if (!selectedPackage || !selectedAmount || !directUpiLink || !modalWhatsAppLink) {
    return;
  }

  selectedPackage.textContent = order.service;
  selectedAmount.textContent = formatAmount(order.amount);
  directUpiLink.href = makePaymentLink(order.service, order.amount, order.orderId);
  modalWhatsAppLink.href = makePaymentConfirmationLink(order);
  directUpiLink.dataset.confirmationLink = makePaymentConfirmationLink(order);

  if (selectedOrderId) {
    selectedOrderId.textContent = order.orderId || "Direct Package";
  }

  if (selectedClientName) {
    selectedClientName.textContent = order.name || "Package Client";
  }
}

function openPaymentModal(order) {
  const paymentModal = qs(".payment-modal");
  if (!paymentModal) {
    return;
  }

  updatePaymentModal(order);
  paymentModal.classList.add("active");
  paymentModal.setAttribute("aria-hidden", "false");
  document.body.classList.add("modal-open");
}

function closePaymentModal() {
  const paymentModal = qs(".payment-modal");
  if (!paymentModal) {
    return;
  }

  paymentModal.classList.remove("active");
  paymentModal.setAttribute("aria-hidden", "true");
  document.body.classList.remove("modal-open");
}

function initPaymentButtons() {
  qsa(".pay-trigger").forEach((button) => {
    button.addEventListener("click", () => {
      const order = {
        orderId: makeOrderId(),
        name: "Package Client",
        phone: "",
        service: button.dataset.package,
        amount: normalizeAmount(button.dataset.amount),
        details: "Monthly package order",
        createdAt: new Date().toISOString(),
      };
      saveOrder(order);
      window.open(makeWhatsAppLink(order), "_blank", "noopener");
      openPaymentModal(order);
    });
  });

  qs("#directUpiLink")?.addEventListener("click", (event) => {
    const confirmationLink = event.currentTarget.dataset.confirmationLink;
    if (confirmationLink) {
      window.open(confirmationLink, "_blank", "noopener");
    }
  });

  qsa("[data-close-payment]").forEach((button) => {
    button.addEventListener("click", closePaymentModal);
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && qs(".payment-modal.active")) {
      closePaymentModal();
    }
  });
}

function initOrderModal() {
  const orderModal = qs(".order-modal");
  const orderForm = qs("#quickOrderForm");
  const selectedService = qs("#orderSelectedService");

  function closeOrderModal() {
    if (!orderModal) {
      return;
    }

    orderModal.classList.remove("active");
    orderModal.setAttribute("aria-hidden", "true");
    document.body.classList.remove("modal-open");
  }

  qsa(".order-trigger").forEach((button) => {
    button.addEventListener("click", () => {
      state.selectedService = button.dataset.service;
      state.selectedAmount = normalizeAmount(button.dataset.amount);
      state.selectedDisplay = formatAmount(button.dataset.amount);
      window.open(makePreOrderWhatsAppLink(state.selectedService, state.selectedAmount), "_blank", "noopener");

      if (selectedService) {
        selectedService.textContent = `${state.selectedService} - ${state.selectedDisplay}`;
      }

      if (orderModal) {
        orderModal.classList.add("active");
        orderModal.setAttribute("aria-hidden", "false");
        document.body.classList.add("modal-open");
        qs("input", orderModal)?.focus();
      }
    });
  });

  qsa("[data-close-order]").forEach((button) => {
    button.addEventListener("click", closeOrderModal);
  });

  if (orderForm) {
    orderForm.addEventListener("submit", (event) => {
      event.preventDefault();
      const formData = new FormData(orderForm);
      const order = {
        orderId: makeOrderId(),
        name: formData.get("name").trim(),
        phone: formData.get("phone").trim(),
        service: state.selectedService,
        amount: normalizeAmount(state.selectedAmount),
        details: formData.get("details").trim(),
        createdAt: new Date().toISOString(),
      };

      saveOrder(order);
      closeOrderModal();
      openPaymentModal(order);
      orderForm.reset();
    });
  }

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && orderModal && orderModal.classList.contains("active")) {
      closeOrderModal();
    }
  });
}

function initUrgencySlots() {
  const slots = Math.floor(Math.random() * 5) + 2;
  qsa("#slotsLeftMain, #slotsLeftPayment").forEach((item) => {
    item.textContent = `Only ${slots} slots left today`;
  });
}

function initOrderTracking() {
  const form = qs("[data-order-tracking-form]");
  const result = qs("[data-tracking-result]");

  if (!form || !result) {
    return;
  }

  form.addEventListener("submit", (event) => {
    event.preventDefault();
    const orderId = new FormData(form).get("orderId").trim().toUpperCase();
    const order = readOrders().find((item) => String(item.orderId).toUpperCase() === orderId);

    if (!order) {
      result.textContent = "No saved order found on this device. Please check the Order ID or contact on WhatsApp.";
      result.classList.remove("found");
      return;
    }

    result.innerHTML = `
      <strong>${order.service} - ${formatAmount(order.amount)}</strong>
      <span>Order ID: ${order.orderId}</span>
      <span>Client: ${order.name || "Client"}</span>
      <span>Status: Payment / WhatsApp confirmation pending</span>
    `;
    result.classList.add("found");
  });
}

function initReviewSystem() {
  const popup = qs("[data-review-popup]");
  const closeButton = qs("[data-close-review]");
  const saveButton = qs("[data-save-review]");
  const reviewText = qs("[data-review-text]");
  const starButtons = qsa("[data-rating]");
  const track = qs("[data-review-track]");
  let selectedRating = 5;

  function closePopup() {
    if (!popup) {
      return;
    }

    popup.classList.remove("active");
    popup.setAttribute("aria-hidden", "true");
    localStorage.setItem(reviewPopupKey, "true");
  }

  function renderStoredReviews() {
    if (!track) {
      return;
    }

    let reviews = [];
    try {
      reviews = JSON.parse(localStorage.getItem(reviewsKey) || "[]");
    } catch (error) {
      reviews = [];
    }

    reviews.slice(0, 4).forEach((review) => {
      const card = document.createElement("article");
      card.className = "review-card";
      card.innerHTML = `
        <strong>Client Review</strong>
        <p>${escapeHtml(review.text)}</p>
        <span>${"★".repeat(review.rating)}</span>
      `;
      track.appendChild(card);
    });

    [...track.children].forEach((card) => {
      const clone = card.cloneNode(true);
      clone.setAttribute("aria-hidden", "true");
      track.appendChild(clone);
    });
  }

  renderStoredReviews();

  if (!popup) {
    return;
  }

  starButtons.forEach((button) => {
    button.addEventListener("click", () => {
      selectedRating = Number(button.dataset.rating);
      starButtons.forEach((item) => item.classList.toggle("active", Number(item.dataset.rating) <= selectedRating));
    });
    button.classList.toggle("active", Number(button.dataset.rating) <= selectedRating);
  });

  if (!localStorage.getItem(reviewPopupKey)) {
    window.setTimeout(() => {
      popup.classList.add("active");
      popup.setAttribute("aria-hidden", "false");
    }, 8000);
  }

  closeButton?.addEventListener("click", closePopup);

  saveButton?.addEventListener("click", () => {
    const text = reviewText?.value.trim() || "Premium service and smooth delivery.";
    let reviews = [];
    try {
      reviews = JSON.parse(localStorage.getItem(reviewsKey) || "[]");
    } catch (error) {
      reviews = [];
    }

    reviews.unshift({ rating: selectedRating, text, createdAt: new Date().toISOString() });
    localStorage.setItem(reviewsKey, JSON.stringify(reviews.slice(0, 12)));
    closePopup();
  });
}

function initOrderModeToggle() {
  const buttons = qsa("[data-order-mode]");
  const panels = qsa("[data-order-panel]");

  function setMode(mode, shouldScroll = true) {
    buttons.forEach((item) => item.classList.toggle("active", item.dataset.orderMode === mode));
    panels.forEach((panel) => panel.classList.toggle("active", panel.dataset.orderPanel === mode));

    if (shouldScroll) {
      qs(`[data-order-panel="${mode}"]`)?.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  }

  buttons.forEach((button) => {
    button.addEventListener("click", () => {
      setMode(button.dataset.orderMode);
    });
  });

  qsa('a[href="#packages-main"]').forEach((link) => {
    link.addEventListener("click", () => setMode("package", false));
  });

  qsa('a[href="#services"]').forEach((link) => {
    link.addEventListener("click", () => setMode("single", false));
  });
}

function initSavedOrderPreview() {
  const card = qs("#savedOrderCard");
  const title = qs("#savedOrderTitle");
  const meta = qs("#savedOrderMeta");
  const order = readLatestOrder();

  if (!card || !title || !meta || !order) {
    return;
  }

  card.hidden = false;
  title.textContent = `${order.service} - ${formatAmount(order.amount)}`;
  meta.textContent = `${order.orderId} | ${order.name || "Client"} | ${order.phone || "Phone not added"}`;

  qs("#payLatestOrder")?.addEventListener("click", () => openPaymentModal(order));
}

function initButtonRipples() {
  qsa(".btn, .mode-option").forEach((button) => {
    button.addEventListener("click", (event) => {
      const ripple = document.createElement("span");
      const rect = button.getBoundingClientRect();
      const size = Math.max(rect.width, rect.height);
      ripple.className = "ripple";
      ripple.style.width = `${size}px`;
      ripple.style.height = `${size}px`;
      ripple.style.left = `${event.clientX - rect.left - size / 2}px`;
      ripple.style.top = `${event.clientY - rect.top - size / 2}px`;
      button.appendChild(ripple);
      ripple.addEventListener("animationend", () => ripple.remove());

      button.classList.add("is-clicking");
      window.setTimeout(() => button.classList.remove("is-clicking"), 180);
    });
  });
}

function initCursorGlow() {
  if (window.matchMedia("(pointer: coarse)").matches) {
    return;
  }

  const glow = document.createElement("span");
  glow.className = "cursor-glow";
  document.body.appendChild(glow);

  let mouseX = -400;
  let mouseY = -400;
  let currentX = mouseX;
  let currentY = mouseY;

  function animateGlow() {
    currentX += (mouseX - currentX) * 0.16;
    currentY += (mouseY - currentY) * 0.16;
    glow.style.transform = `translate3d(${currentX}px, ${currentY}px, 0)`;
    requestAnimationFrame(animateGlow);
  }

  window.addEventListener("pointermove", (event) => {
    mouseX = event.clientX;
    mouseY = event.clientY;
    glow.classList.add("active");
  });

  window.addEventListener("pointerleave", () => glow.classList.remove("active"));
  animateGlow();
}

function initTiltCards() {
  if (window.matchMedia("(pointer: coarse), (max-width: 860px)").matches) {
    return;
  }

  qsa(".service-card, .package-card").forEach((card) => {
    card.addEventListener("pointermove", (event) => {
      const rect = card.getBoundingClientRect();
      const x = (event.clientX - rect.left) / rect.width - 0.5;
      const y = (event.clientY - rect.top) / rect.height - 0.5;
      card.style.transform = `perspective(1000px) rotateX(${y * -8}deg) rotateY(${x * 8}deg) translateY(-8px) scale(1.01)`;
    });

    card.addEventListener("pointerleave", () => {
      card.style.transform = "";
    });
  });
}

function initParallax() {
  const hero = qs(".portfolio-hero picture img") || qs(".landing-logo");
  const paymentHero = qs(".hero-payment");
  const mainNature = qs(".main-nature-bg");
  if ((!hero && !paymentHero && !mainNature) || window.matchMedia("(max-width: 680px)").matches) {
    return;
  }

  let scrollTicking = false;

  function updateScrollDepth() {
    const scrollDepth = Math.min(window.scrollY / Math.max(window.innerHeight, 1), 2);
    document.documentElement.style.setProperty("--main-scroll-depth", `${scrollDepth * -18}px`);
    scrollTicking = false;
  }

  window.addEventListener("pointermove", (event) => {
    const x = (event.clientX / window.innerWidth - 0.5) * 12;
    const y = (event.clientY / window.innerHeight - 0.5) * 12;
    document.documentElement.style.setProperty("--parallax-x", `${x}px`);
    document.documentElement.style.setProperty("--parallax-y", `${y}px`);
    document.documentElement.style.setProperty("--nature-x", `${x * -0.6}px`);
    document.documentElement.style.setProperty("--nature-y", `${y * -0.45}px`);
    document.documentElement.style.setProperty("--main-nature-x", `${x * -0.75}px`);
    document.documentElement.style.setProperty("--main-nature-y", `calc(${y * -0.55}px + var(--main-scroll-depth, 0px))`);
  });

  window.addEventListener("scroll", () => {
    if (!scrollTicking) {
      scrollTicking = true;
      requestAnimationFrame(updateScrollDepth);
    }
  }, { passive: true });

  updateScrollDepth();
}

initPageLoader();
initRevealAnimations();
initParticles();
initLightbox();
initPaymentButtons();
initOrderModal();
initOrderModeToggle();
initSavedOrderPreview();
initButtonRipples();
initCursorGlow();
initTiltCards();
initParallax();
initUrgencySlots();
initOrderTracking();
initReviewSystem();
